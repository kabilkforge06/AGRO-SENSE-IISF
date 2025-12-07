const http = require('http');

// Test the health endpoint
const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/health',
  method: 'GET'
};

const req = http.request(options, (res) => {
  let data = '';
  
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('Health Check Response:');
    console.log(JSON.parse(data));
  });
});

req.on('error', (error) => {
  console.error('Error testing health endpoint:', error.message);
  console.log('Make sure the server is running with: npm start');
});

req.end();