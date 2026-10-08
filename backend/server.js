const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
require('dotenv').config();

const app = express();

// ==========================================
// 1. CONFIGURAÇÕES OBRIGATÓRIAS
// ==========================================
app.use(cors());
app.use(express.json());

// Detetor de tráfego no terminal
app.use((req, res, next) => {
    console.log(`---> [PEDIDO RECEBIDO] Método: ${req.method} | Rota: ${req.url}`);
    next();
});

// ==========================================
// 2. CONEXÃO E CRIAÇÃO AUTOMÁTICA DE TABELAS
// ==========================================
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false }
});

async function initDB() {
  try {
    await pool.query('SELECT NOW()');
    console.log('✅ Banco de dados PostgreSQL (Neon) conectado com sucesso.');

    // Criar todas as tabelas automaticamente se não existirem
    await pool.query(`
      CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        email VARCHAR(100) UNIQUE NOT NULL,
        password VARCHAR(100) NOT NULL,
        role VARCHAR(20) NOT NULL
      );

      CREATE TABLE IF NOT EXISTS classes (
        id SERIAL PRIMARY KEY,
        materia VARCHAR(100) NOT NULL,
        turma VARCHAR(100) NOT NULL
      );

      CREATE TABLE IF NOT EXISTS student_classes (
        id SERIAL PRIMARY KEY,
        student_id INT NOT NULL,
        class_id INT NOT NULL,
        enrolled_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE(student_id, class_id)
      );

      CREATE TABLE IF NOT EXISTS attendance_records (
        id SERIAL PRIMARY KEY,
        student_id INT NOT NULL,
        class_id INT NOT NULL,
        status VARCHAR(20) NOT NULL,
        date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );

      CREATE TABLE IF NOT EXISTS medical_certificates (
        id SERIAL PRIMARY KEY,
        student_id INT NOT NULL,
        class_id INT NOT NULL,
        reason TEXT NOT NULL,
        status VARCHAR(50) DEFAULT 'Pendente',
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Todas as tabelas foram verificadas e criadas com sucesso no Neon.');

  } catch (err) {
    console.error('❌ Erro ao configurar o banco Neon:', err);
  }
}

initDB();

// ==========================================
// 3. ROTAS DE AUTENTICAÇÃO
// ==========================================
app.post('/register', async (req, res) => {
  try {
    const { name, email, password, role } = req.body;
    const userExists = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userExists.rows.length > 0) {
      return res.status(400).json({ error: 'Este email já está registado.' });
    }

    const newUser = await pool.query(
      'INSERT INTO users (name, email, password, role) VALUES ($1, $2, $3, $4) RETURNING id, name, email, role',
      [name, email, password, role]
    );
    res.status(201).json({ message: 'Utilizador registado com sucesso!', user: newUser.rows[0] });
  } catch (error) {
    console.error('❌ Erro no /register:', error);
    res.status(500).json({ error: 'Erro interno no servidor.' });
  }
});

app.post('/login', async (req, res) => {
  try {
    const { email, password } = req.body;
    const userResult = await pool.query('SELECT * FROM users WHERE email = $1', [email]);
    if (userResult.rows.length === 0 || userResult.rows[0].password !== password) {
      return res.status(401).json({ error: 'Credenciais inválidas.' });
    }
    const user = userResult.rows[0];
    res.status(200).json({ token: 'token_jwt_123', name: user.name, role: user.role });
  } catch (error) {
    console.error('❌ Erro no /login:', error);
    res.status(500).json({ error: 'Erro interno no servidor.' });
  }
});

// ==========================================
// 4. ROTAS DE TURMAS (PROFESSOR)
// ==========================================
app.post('/api/classes', async (req, res) => {
  try {
    const { materia, turma } = req.body;
    if (!materia || !turma) {
      return res.status(400).json({ error: 'Matéria e turma são obrigatórias.' });
    }
    const newClass = await pool.query(
      'INSERT INTO classes (materia, turma) VALUES ($1, $2) RETURNING *',
      [materia, turma]
    );
    res.status(201).json(newClass.rows[0]);
  } catch (error) {
    console.error('❌ Erro ao criar turma:', error);
    res.status(500).json({ error: 'Erro interno ao criar turma.' });
  }
});

app.get('/api/classes', async (req, res) => {
  try {
    const allClasses = await pool.query('SELECT * FROM classes ORDER BY id DESC');
    res.status(200).json(allClasses.rows);
  } catch (error) {
    console.error('❌ Erro ao buscar turmas:', error);
    res.status(500).json({ error: 'Erro interno ao buscar turmas.' });
  }
});

// NOVO: Buscar alunos matriculados numa turma específica
app.get('/api/classes/:class_id/students', async (req, res) => {
  try {
    const { class_id } = req.params;
    const query = `
      SELECT u.id, u.name, u.email, st.enrolled_at
      FROM users u
      JOIN student_classes st ON u.id = st.student_id
      WHERE st.class_id = $1 AND u.role = 'aluno'
    `;
    const result = await pool.query(query, [class_id]);
    res.status(200).json(result.rows);
  } catch (error) {
    console.error('❌ Erro ao buscar alunos da turma:', error);
    res.status(500).json({ error: 'Erro interno ao buscar alunos.' });
  }
});

// ==========================================
// 5. ROTAS DO ALUNO (MATRÍCULAS, QR CODE E ATESTADOS)
// ==========================================
app.post('/api/student/enroll', async (req, res) => {
  try {
    const { student_id, class_id } = req.body;
    const check = await pool.query(
      'SELECT * FROM student_classes WHERE student_id = $1 AND class_id = $2',
      [student_id, class_id]
    );
    if (check.rows.length > 0) {
      return res.status(400).json({ error: 'Já está matriculado nesta turma.' });
    }
    const enrollment = await pool.query(
      'INSERT INTO student_classes (student_id, class_id) VALUES ($1, $2) RETURNING *',
      [student_id, class_id]
    );
    res.status(201).json({ message: 'Matrícula efetuada!', enrollment: enrollment.rows[0] });
  } catch (error) {
    console.error('❌ Erro ao matricular:', error);
    res.status(500).json({ error: 'Erro ao matricular.' });
  }
});

app.post('/api/student/attendance', async (req, res) => {
  try {
    const { student_id, class_id } = req.body;
    const result = await pool.query(
      'INSERT INTO attendance_records (student_id, class_id, status) VALUES ($1, $2, $3) RETURNING *',
      [student_id, class_id, 'Presente']
    );
    res.status(201).json({ message: 'Presença marcada com sucesso!', record: result.rows[0] });
  } catch (error) {
    console.error('❌ Erro ao marcar presença:', error);
    res.status(500).json({ error: 'Erro ao marcar presença.' });
  }
});

app.post('/api/student/certificate', async (req, res) => {
  try {
    const { student_id, class_id, reason } = req.body;
    const newCert = await pool.query(
      'INSERT INTO medical_certificates (student_id, class_id, reason) VALUES ($1, $2, $3) RETURNING *',
      [student_id, class_id, reason]
    );
    res.status(201).json({ message: 'Atestado enviado!', certificate: newCert.rows[0] });
  } catch (error) {
    console.error('❌ Erro ao enviar atestado:', error);
    res.status(500).json({ error: 'Erro ao enviar atestado.' });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`🚀 Servidor rodando na porta ${PORT}`);
});