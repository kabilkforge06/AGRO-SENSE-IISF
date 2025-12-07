const axios = require('axios');

const PROXY_URL = 'http://localhost:3001';

async function testTextSearch() {
  console.log('\n🧪 Testing Text Search for Cold Storage...\n');
  
  try {
    const response = await axios.get(`${PROXY_URL}/api/places/textsearch`, {
      params: {
        query: 'Cold storage in Panchkula, Haryana'
      }
    });

    console.log('✅ Text Search Response:');
    console.log('Status:', response.data.status);
    console.log('Results found:', response.data.results?.length || 0);
    
    if (response.data.results && response.data.results.length > 0) {
      console.log('\n📍 Cold Storage Locations:');
      response.data.results.slice(0, 5).forEach((place, index) => {
        console.log(`\n${index + 1}. ${place.name}`);
        console.log(`   Address: ${place.formatted_address}`);
        console.log(`   Location: ${place.geometry.location.lat}, ${place.geometry.location.lng}`);
        console.log(`   Rating: ${place.rating || 'N/A'}`);
      });
    } else {
      console.log('⚠️  No results found');
    }

  } catch (error) {
    console.error('❌ Text Search Error:');
    console.error('Message:', error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', JSON.stringify(error.response.data, null, 2));
    }
  }
}

async function testNearbySearch() {
  console.log('\n🧪 Testing Nearby Search for Cold Storage...\n');
  
  // Panchkula coordinates
  const lat = 30.6942;
  const lng = 76.8606;
  
  try {
    const response = await axios.get(`${PROXY_URL}/api/places/nearbysearch`, {
      params: {
        location: `${lat},${lng}`,
        radius: 10000,
        keyword: 'cold storage'
      }
    });

    console.log('✅ Nearby Search Response:');
    console.log('Status:', response.data.status);
    console.log('Results found:', response.data.results?.length || 0);
    
    if (response.data.results && response.data.results.length > 0) {
      console.log('\n📍 Nearby Cold Storage Locations:');
      response.data.results.slice(0, 5).forEach((place, index) => {
        console.log(`\n${index + 1}. ${place.name}`);
        console.log(`   Address: ${place.formatted_address}`);
        console.log(`   Location: ${place.geometry.location.lat}, ${place.geometry.location.lng}`);
        console.log(`   Rating: ${place.rating || 'N/A'}`);
      });
    } else {
      console.log('⚠️  No results found');
    }

  } catch (error) {
    console.error('❌ Nearby Search Error:');
    console.error('Message:', error.message);
    if (error.response) {
      console.error('Status:', error.response.status);
      console.error('Data:', JSON.stringify(error.response.data, null, 2));
    }
  }
}

async function testHealthCheck() {
  console.log('🏥 Testing Health Check...\n');
  
  try {
    const response = await axios.get(`${PROXY_URL}/health`);
    console.log('✅ Server is healthy:', response.data);
  } catch (error) {
    console.error('❌ Health check failed:', error.message);
    console.error('⚠️  Make sure the proxy server is running: cd places-proxy && npm start');
    return false;
  }
  return true;
}

async function runTests() {
  console.log('='.repeat(60));
  console.log('🧪 COLD STORAGE API TEST');
  console.log('='.repeat(60));

  const isHealthy = await testHealthCheck();
  
  if (!isHealthy) {
    console.log('\n❌ Server is not running. Please start it first.');
    return;
  }

  await testTextSearch();
  await testNearbySearch();

  console.log('\n' + '='.repeat(60));
  console.log('✅ Tests completed');
  console.log('='.repeat(60) + '\n');
}

runTests();
