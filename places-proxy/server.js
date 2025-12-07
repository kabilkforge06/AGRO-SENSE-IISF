const express = require('express');
const cors = require('cors');
const axios = require('axios');

const app = express();
const PORT = 3001;

// ⭐ USE ONLY YOUR NEW PROJECT API KEY (NO FALLBACK)
const GOOGLE_API_KEY = "AIzaSyA-Fy_Jpvkq0hg6Lv7Psz3PG9cVULJXuTs";

app.use(cors({ origin: "*", methods: ["GET", "POST", "OPTIONS"] }));
app.use(express.json());

app.get("/health", (req, res) => {
  res.json({ status: "ok", message: "Places API Proxy is running" });
});

// ===========================================================
// ⭐ TEXT SEARCH (NEW GOOGLE PLACES API v1)
// ===========================================================
app.post('/api/places/textsearch', async (req, res) => {
  try {
    const { query, location, radius } = req.body;

    if (!query) return res.status(400).json({ error: "Query required" });

    console.log(`🔎 Text Search: ${query}`);

    const body = { textQuery: query };

    if (location && radius) {
      const [lat, lng] = location.split(",").map(parseFloat);
      body.locationBias = {
        circle: {
          center: { latitude: lat, longitude: lng },
          radius: parseInt(radius)
        }
      };
    }

    const response = await axios.post(
      "https://places.googleapis.com/v1/places:searchText",
      body,
      {
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": GOOGLE_API_KEY,
          "X-Goog-FieldMask":
            "places.id,places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.photos"
        }
      }
    );

    res.json({
      status: "OK",
      results: (response.data.places || []).map(place => ({
        place_id: place.id,
        name: place.displayName?.text || "Unknown",
        formatted_address: place.formattedAddress,
        geometry: { location: place.location },
        rating: place.rating,
        user_ratings_total: place.userRatingCount,
        photos: (place.photos || []).map(p => ({ photo_reference: p.name }))
      }))
    });

  } catch (err) {
    console.error("❌ Text Search Error:", err.response?.data || err.message);
    res.status(err.response?.status || 500).json({
      error: err.response?.data || err.message
    });
  }
});

// ===========================================================
// ⭐ NEARBY SEARCH (NEW GOOGLE PLACES API v1)
// ===========================================================
app.post('/api/places/nearbysearch', async (req, res) => {
  try {
    const { location, radius } = req.body;

    if (!location || !radius)
      return res.status(400).json({ error: "Location and radius required" });

    const [lat, lng] = location.split(",").map(parseFloat);

    console.log(`📍 Nearby Search: ${lat}, ${lng} (radius ${radius})`);

    const body = {
      locationRestriction: {
        circle: {
          center: { latitude: lat, longitude: lng },
          radius: parseInt(radius)
        }
      }
    };

    const response = await axios.post(
      "https://places.googleapis.com/v1/places:searchNearby",
      body,
      {
        headers: {
          "Content-Type": "application/json",
          "X-Goog-Api-Key": GOOGLE_API_KEY,
          "X-Goog-FieldMask":
            "places.id,places.displayName,places.formattedAddress,places.location,places.rating,places.userRatingCount,places.photos"
        }
      }
    );

    res.json({
      status: "OK",
      results: (response.data.places || []).map(place => ({
        place_id: place.id,
        name: place.displayName?.text,
        formatted_address: place.formattedAddress,
        geometry: { location: place.location },
        rating: place.rating,
        user_ratings_total: place.userRatingCount,
        photos: (place.photos || []).map(p => ({ photo_reference: p.name }))
      }))
    });

  } catch (err) {
    console.error("❌ Nearby Search Error:", err.response?.data || err.message);
    res.status(err.response?.status || 500).json({
      error: err.response?.data || err.message
    });
  }
});

app.listen(PORT, () => {
  console.log(`🚀 Proxy running at http://localhost:${PORT}`);
});
