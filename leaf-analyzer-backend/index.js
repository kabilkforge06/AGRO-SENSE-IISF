const express = require('express');
const cors = require('cors');
const multer = require('multer');
const vision = require('@google-cloud/vision');
require('dotenv').config();

const app = express();
const port = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// Configure multer for file uploads
const upload = multer({
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB limit
  },
  fileFilter: (req, file, cb) => {
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Only image files are allowed!'), false);
    }
  }
});

// Initialize Google Cloud Vision client
const client = new vision.ImageAnnotatorClient({
  keyFilename: process.env.GOOGLE_CLOUD_KEY_FILE || './service-account-key.json',
  projectId: process.env.GOOGLE_CLOUD_PROJECT_ID || 'your-project-id'
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({
    status: 'healthy',
    message: 'Leaf Analyzer Backend is running',
    timestamp: new Date().toISOString()
  });
});

// Analyze leaf image endpoint
app.post('/analyze-leaf', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        error: 'No image file provided'
      });
    }

    const imageBuffer = req.file.buffer;

    // Perform text detection (you can also use label detection or custom model)
    const [result] = await client.textDetection({
      image: { content: imageBuffer }
    });

    // Perform label detection for plant analysis
    const [labelResult] = await client.labelDetection({
      image: { content: imageBuffer }
    });

    const labels = labelResult.labelAnnotations || [];
    const textAnnotations = result.textAnnotations || [];

    // Basic plant health analysis based on labels
    const plantLabels = labels.filter(label => 
      label.description.toLowerCase().includes('leaf') ||
      label.description.toLowerCase().includes('plant') ||
      label.description.toLowerCase().includes('disease') ||
      label.description.toLowerCase().includes('healthy') ||
      label.description.toLowerCase().includes('damage')
    );

    // Simple health assessment
    let healthStatus = 'Unknown';
    let confidence = 0;
    let recommendations = [];

    if (plantLabels.length > 0) {
      const healthyKeywords = ['healthy', 'green', 'fresh'];
      const diseaseKeywords = ['disease', 'damage', 'brown', 'yellow', 'spot'];

      const isHealthy = plantLabels.some(label => 
        healthyKeywords.some(keyword => 
          label.description.toLowerCase().includes(keyword)
        )
      );

      const isDiseased = plantLabels.some(label => 
        diseaseKeywords.some(keyword => 
          label.description.toLowerCase().includes(keyword)
        )
      );

      if (isHealthy && !isDiseased) {
        healthStatus = 'Healthy';
        confidence = Math.max(...plantLabels.map(l => l.score)) * 100;
        recommendations = [
          'Continue current care routine',
          'Monitor regularly for any changes',
          'Maintain proper watering schedule'
        ];
      } else if (isDiseased) {
        healthStatus = 'Potentially Diseased';
        confidence = Math.max(...plantLabels.map(l => l.score)) * 100;
        recommendations = [
          'Consult with agricultural expert',
          'Consider appropriate treatment',
          'Isolate affected plants if necessary',
          'Improve ventilation and reduce humidity'
        ];
      } else {
        healthStatus = 'Needs Further Analysis';
        confidence = 50;
        recommendations = [
          'Take clearer photos of affected areas',
          'Consult with local agricultural extension',
          'Monitor plant closely for changes'
        ];
      }
    }

    res.json({
      success: true,
      analysis: {
        healthStatus,
        confidence: Math.round(confidence),
        detectedLabels: plantLabels.map(label => ({
          name: label.description,
          confidence: Math.round(label.score * 100)
        })),
        recommendations,
        analysisDate: new Date().toISOString()
      },
      rawData: {
        labels: labels.slice(0, 10), // Top 10 labels
        textDetected: textAnnotations.length > 0
      }
    });

  } catch (error) {
    console.error('Error analyzing image:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to analyze image',
      message: error.message
    });
  }
});

// Error handling middleware
app.use((error, req, res, next) => {
  if (error instanceof multer.MulterError) {
    if (error.code === 'LIMIT_FILE_SIZE') {
      return res.status(400).json({
        success: false,
        error: 'File too large. Maximum size is 10MB.'
      });
    }
  }
  
  console.error('Unhandled error:', error);
  res.status(500).json({
    success: false,
    error: 'Internal server error'
  });
});

// 404 handler
app.use('*', (req, res) => {
  res.status(404).json({
    success: false,
    error: 'Endpoint not found'
  });
});

app.listen(port, () => {
  console.log(`Leaf Analyzer Backend running on port ${port}`);
  console.log(`Health check available at: http://localhost:${port}/health`);
});