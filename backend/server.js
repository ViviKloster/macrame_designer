const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const app = express();
const port = 3001;

// Middleware
app.use(cors());
app.use(express.json());

// Crear pool de conexiones
const pool = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'macrame_designerdb',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    enableKeepAlive: true,
    keepAliveInitialDelay: 0
});

// Verificar conexión y crear tabla si no existe
pool.getConnection((err, connection) => {
  if (err) {
    console.error('❌ ERROR conectando a MySQL:', err.message);
    console.log('⚠️  Asegúrate de:');
    console.log('   1. XAMPP MySQL esté EN VERDE');
    console.log('   2. Base de datos "macrame_designerdb" exista');
    console.log('   3. Usuario: root, Contraseña: (vacía)');
  } else {
    console.log('✅ Conectado a MySQL: macrame_designerdb');
    
    // Crear tabla projects si no existe
    const createTableSQL = `
      CREATE TABLE IF NOT EXISTS projects (
        id INT PRIMARY KEY AUTO_INCREMENT,
        name VARCHAR(255) NOT NULL,
        description TEXT,
        cell_size INT DEFAULT 20,
        cord_thickness INT DEFAULT 3,
        cord_color VARCHAR(50) DEFAULT '#000000',
        grid_data JSON DEFAULT NULL,  -- ← COLUMNA PARA LOS NUDOS
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `;
    
    connection.query(createTableSQL, (err) => {
      if (err) {
        console.error('❌ Error creando tabla:', err.message);
      } else {
        console.log('✅ Tabla "projects" verificada/creada');
        console.log('   - Incluye columna grid_data para almacenar nudos');
      }
      connection.release(); // Importante: liberar conexión
    });
  }
});

// Ruta de prueba MEJORADA
app.get('/api/test', (req, res) => {
  pool.query('SELECT 1 as test, NOW() as time', (err, results) => {
    if (err) {
      console.error('❌ Error en test query:', err.message);
      return res.status(500).json({ 
        error: 'Database error',
        details: err.message,
        code: err.code 
      });
    }
    res.json({ 
      status: '✅ API funcionando',
      database: 'Conectada',
      data: results[0],
      timestamp: new Date().toISOString()
    });
  });
});

// ✅ Ruta para guardar diseño (CON NUDOS)
app.post('/api/designs', (req, res) => {
  console.log('📦 Recibiendo POST /designs');
  console.log('📥 Body recibido:', JSON.stringify(req.body, null, 2));
  
  const { 
    name, 
    description = '', 
    cellSize = 20, 
    cordThickness = 3, 
    cordColor = '#000000',
    knots = [],  // ← Nudos del frontend
    gridData = []  // También puede venir como gridData
  } = req.body;
  
  if (!name) {
    console.log('❌ Error: Nombre requerido');
    return res.status(400).json({ 
      error: 'El nombre es requerido',
      received: req.body 
    });
  }
  
  // Usar knots o gridData (lo que venga del frontend)
  const knotsData = knots.length > 0 ? knots : gridData;
  
  console.log(`🔧 Guardando: "${name}" con ${knotsData.length} nudos`);
  
  const query = `
    INSERT INTO projects 
    (name, description, cell_size, cord_thickness, cord_color, grid_data) 
    VALUES (?, ?, ?, ?, ?, ?)
  `;
  
  const values = [
    name, 
    description, 
    cellSize, 
    cordThickness, 
    cordColor,
    knotsData.length > 0 ? JSON.stringify(knotsData) : null  // Guardar nudos como JSON
  ];
  
  console.log('📝 Query:', query);
  console.log('📝 Valores:', values);
  
  pool.query(query, values, (err, result) => {
    if (err) {
      console.error('❌ ERROR MySQL:', {
        code: err.code,
        message: err.message,
        sql: err.sql,
        values: values
      });
      
      return res.status(500).json({ 
        error: 'Error de base de datos',
        code: err.code,
        message: err.message,
        details: 'Verifica que la tabla "projects" exista'
      });
    }
    
    console.log(`✅ Proyecto guardado. ID: ${result.insertId}`);
    console.log(`   Nudos almacenados: ${knotsData.length}`);
    
    res.json({
      success: true,
      projectId: result.insertId,
      message: `Diseño "${name}" guardado exitosamente`,
      timestamp: new Date().toISOString(),
      data: {
        id: result.insertId,
        name,
        description,
        cellSize,
        cordThickness,
        cordColor,
        knotsCount: knotsData.length
      }
    });
  });
});

// Ruta para obtener diseños
app.get('/api/designs', (req, res) => {
  console.log('📥 GET /api/designs');
  
  pool.query('SELECT * FROM projects ORDER BY created_at DESC', (err, results) => {
    if (err) {
      console.error('❌ Error obteniendo proyectos:', err.message);
      return res.status(500).json({ 
        error: err.message,
        code: err.code 
      });
    }
    
    // Procesar resultados para incluir conteo de nudos
    const processedResults = results.map(project => {
      let knotsCount = 0;
      if (project.grid_data) {
        try {
          const gridData = JSON.parse(project.grid_data);
          knotsCount = Array.isArray(gridData) ? gridData.length : 0;
        } catch (e) {
          console.error('❌ Error parseando grid_data:', e);
        }
      }
      
      return {
        ...project,
        knots_count: knotsCount  // Agregar conteo de nudos
      };
    });
    
    console.log(`✅ ${processedResults.length} proyectos encontrados`);
    
    res.json({
      success: true,
      count: processedResults.length,
      data: processedResults
    });
  });
});

// Ruta para obtener un diseño específico (CON NUDOS)
app.get('/api/designs/:id', (req, res) => {
  const { id } = req.params;
  console.log(`🔍 Obteniendo diseño ID: ${id}`);
  
  pool.query('SELECT * FROM projects WHERE id = ?', [id], (err, results) => {
    if (err) {
      console.error('❌ Error obteniendo proyecto:', err.message);
      return res.status(500).json({ error: err.message });
    }
    
    if (results.length === 0) {
      console.log(`❌ Proyecto ID ${id} no encontrado`);
      return res.status(404).json({ 
        success: false,
        error: 'Proyecto no encontrado' 
      });
    }
    
    const project = results[0];
    
    // Parsear grid_data si existe
    let knotsData = [];
    if (project.grid_data) {
      try {
        knotsData = JSON.parse(project.grid_data);
        console.log(`✅ ${knotsData.length} nudos parseados del proyecto`);
      } catch (e) {
        console.error('❌ Error parseando grid_data:', e);
      }
    }
    
    console.log(`✅ Diseño encontrado: "${project.name}"`);
    
    // Preparar respuesta estructurada
    const responseData = {
      id: project.id,
      name: project.name,
      description: project.description,
      cell_size: project.cell_size,
      cellSize: project.cell_size,  // Doble compatibilidad
      cord_thickness: project.cord_thickness,
      cordThickness: project.cord_thickness,  // Doble compatibilidad
      cord_color: project.cord_color,
      cordColor: project.cord_color,  // Doble compatibilidad
      knots: knotsData,  // Nudos en formato array
      gridData: knotsData,  // También como gridData para compatibilidad
      knots_count: knotsData.length,
      created_at: project.created_at,
      createdAt: project.created_at,  // Doble compatibilidad
      updated_at: project.updated_at,
      updatedAt: project.updated_at  // Doble compatibilidad
    };
    
    res.json({
      success: true,
      data: responseData
    });
  });
});

// Ruta para eliminar un diseño
app.delete('/api/designs/:id', (req, res) => {
  const { id } = req.params;
  console.log(`🗑️  Eliminando diseño ID: ${id}`);
  
  pool.query('DELETE FROM projects WHERE id = ?', [id], (err, result) => {
    if (err) {
      console.error('❌ Error eliminando proyecto:', err.message);
      return res.status(500).json({ error: err.message });
    }
    
    if (result.affectedRows === 0) {
      console.log(`❌ Proyecto ID ${id} no encontrado para eliminar`);
      return res.status(404).json({ error: 'Proyecto no encontrado' });
    }
    
    console.log(`✅ Proyecto ID ${id} eliminado exitosamente`);
    
    res.json({
      success: true,
      message: 'Proyecto eliminado exitosamente'
    });
  });
});

// Ruta para actualizar un diseño
app.put('/api/designs/:id', (req, res) => {
  const { id } = req.params;
  console.log(`✏️  Actualizando diseño ID: ${id}`);
  console.log('📥 Datos recibidos:', req.body);
  
  const { 
    name, 
    description, 
    cellSize, 
    cordThickness, 
    cordColor,
    knots,
    gridData 
  } = req.body;
  
  // Preparar los campos a actualizar
  const updates = [];
  const values = [];
  
  if (name !== undefined) {
    updates.push('name = ?');
    values.push(name);
  }
  
  if (description !== undefined) {
    updates.push('description = ?');
    values.push(description);
  }
  
  if (cellSize !== undefined) {
    updates.push('cell_size = ?');
    values.push(cellSize);
  }
  
  if (cordThickness !== undefined) {
    updates.push('cord_thickness = ?');
    values.push(cordThickness);
  }
  
  if (cordColor !== undefined) {
    updates.push('cord_color = ?');
    values.push(cordColor);
  }
  
  // Actualizar nudos si se envían
  const knotsData = knots || gridData;
  if (knotsData !== undefined) {
    updates.push('grid_data = ?');
    values.push(knotsData.length > 0 ? JSON.stringify(knotsData) : null);
  }
  
  if (updates.length === 0) {
    return res.status(400).json({ 
      error: 'No se proporcionaron datos para actualizar' 
    });
  }
  
  values.push(id);
  
  const query = `
    UPDATE projects 
    SET ${updates.join(', ')}
    WHERE id = ?
  `;
  
  console.log('📝 Query:', query);
  console.log('📝 Valores:', values);
  
  pool.query(query, values, (err, result) => {
    if (err) {
      console.error('❌ Error actualizando proyecto:', err.message);
      return res.status(500).json({ error: err.message });
    }
    
    if (result.affectedRows === 0) {
      return res.status(404).json({ error: 'Proyecto no encontrado' });
    }
    
    console.log(`✅ Proyecto ID ${id} actualizado exitosamente`);
    
    res.json({
      success: true,
      message: 'Proyecto actualizado exitosamente',
      updatedFields: updates
    });
  });
});

// Ruta de estado del servidor
app.get('/api/health', (req, res) => {
  res.json({
    status: 'online',
    timestamp: new Date().toISOString(),
    service: 'Macrame Designer API',
    version: '1.0.0',
    database: 'MySQL (macrame_designerdb)',
    endpoints: [
      'GET    /api/test',
      'GET    /api/health',
      'POST   /api/designs',
      'GET    /api/designs',
      'GET    /api/designs/:id',
      'PUT    /api/designs/:id',
      'DELETE /api/designs/:id'
    ]
  });
});

// Ruta para verificar estructura de tabla
app.get('/api/debug/table-structure', (req, res) => {
  pool.query('DESCRIBE projects', (err, results) => {
    if (err) {
      console.error('❌ Error obteniendo estructura:', err.message);
      return res.status(500).json({ error: err.message });
    }
    
    res.json({
      success: true,
      table: 'projects',
      structure: results
    });
  });
});

// Middleware para logging de peticiones
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} ${req.method} ${req.url}`);
  next();
});

// Manejo de errores 404
app.use((req, res) => {
  console.log(`❌ Ruta no encontrada: ${req.method} ${req.url}`);
  res.status(404).json({ 
    success: false,
    error: 'Ruta no encontrada',
    method: req.method,
    url: req.url
  });
});

// Manejo de errores global
app.use((err, req, res, next) => {
  console.error('❌ Error global:', err);
  res.status(500).json({
    success: false,
    error: 'Error interno del servidor',
    message: err.message
  });
});

// Iniciar servidor
app.listen(port, () => {
  console.log(`🚀 Backend corriendo en http://localhost:${port}`);
  console.log(`📌 Ruta de prueba: http://localhost:${port}/api/test`);
  console.log(`📌 Estado: http://localhost:${port}/api/health`);
  console.log(`📌 Guardar diseño: POST http://localhost:${port}/api/designs`);
  console.log(`📌 Obtener diseños: GET http://localhost:${port}/api/designs`);
  console.log(`📌 Debug tabla: GET http://localhost:${port}/api/debug/table-structure`);
  console.log(`📌 Base de datos: macrame_designerdb (con grid_data para nudos)`);
});