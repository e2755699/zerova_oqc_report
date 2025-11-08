const functions = require('firebase-functions');
const https = require('https');
const http = require('http');

// Gemini API Key (stored securely in backend)
const GEMINI_API_KEY = 'AIzaSyDIbf5JyyB6BLbbznfTyu5mdUWdk-xnCBg';

// CORS headers
const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization',
};

// Proxy function for OQC API
exports.proxyOqcApi = functions.https.onRequest(async (req, res) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    res.set(corsHeaders);
    res.status(204).send('');
    return;
  }

  try {
    const { baseUrl, endpoint, sn } = req.query;

    if (!baseUrl || !endpoint || !sn) {
      res.set(corsHeaders);
      res.status(400).json({
        error: 'Missing required parameters: baseUrl, endpoint, sn',
      });
      return;
    }

    const token = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyIjoiWmVyb3ZhX09RQyJ9.-glMWnDu11Wm93OFdvRmyrwP2KnQY3J-yUS_W4QZm-k';
    const url = `${baseUrl}${endpoint}?sn=${encodeURIComponent(sn)}`;

    // Parse URL - handle both http:// and https://
    let urlObj;
    try {
      urlObj = new URL(url);
    } catch (e) {
      // If URL parsing fails, try to construct it
      urlObj = new URL(url.startsWith('http') ? url : `http://${url}`);
    }
    const isHttps = urlObj.protocol === 'https:';
    const httpModule = isHttps ? https : http;

    const options = {
      hostname: urlObj.hostname,
      port: urlObj.port || (isHttps ? 443 : 80),
      path: urlObj.pathname + urlObj.search,
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${token}`,
        'Accept': 'application/json',
      },
    };

    // Make request
    const proxyReq = httpModule.request(options, (proxyRes) => {
      let data = '';

      proxyRes.on('data', (chunk) => {
        data += chunk;
      });

      proxyRes.on('end', () => {
        res.set(corsHeaders);
        res.status(proxyRes.statusCode);
        res.setHeader('Content-Type', proxyRes.headers['content-type'] || 'application/json');
        res.send(data);
      });
    });

    proxyReq.on('error', (error) => {
      console.error('Proxy request error:', error);
      res.set(corsHeaders);
      res.status(500).json({
        error: 'Proxy request failed',
        message: error.message,
      });
    });

    proxyReq.end();
  } catch (error) {
    console.error('Function error:', error);
    res.set(corsHeaders);
    res.status(500).json({
      error: 'Internal server error',
      message: error.message,
    });
  }
});

// Gemini validation function
exports.validateWithGemini = functions.https.onRequest(async (req, res) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    res.set(corsHeaders);
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.set(corsHeaders);
    res.status(405).json({ error: 'Method not allowed' });
    return;
  }

  try {
    const { prompt } = req.body;

    if (!prompt) {
      res.set(corsHeaders);
      res.status(400).json({
        error: 'Missing required parameter: prompt',
      });
      return;
    }

    const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/gemini-pro:generateContent?key=${GEMINI_API_KEY}`;

    // Node.js 18+ has built-in fetch, Firebase Functions uses Node 18
    const geminiResponse = await fetch(geminiUrl, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        contents: [{
          parts: [{
            text: prompt
          }]
        }]
      })
    });

    if (!geminiResponse.ok) {
      const errorData = await geminiResponse.text();
      throw new Error(`Gemini API error: ${geminiResponse.status} - ${errorData}`);
    }

    const geminiData = await geminiResponse.json();
    const responseText = geminiData.candidates?.[0]?.content?.parts?.[0]?.text || '';

    res.set(corsHeaders);
    res.status(200).json({
      responseText: responseText,
      success: true
    });
  } catch (error) {
    console.error('Gemini validation error:', error);
    res.set(corsHeaders);
    res.status(500).json({
      error: 'Gemini validation failed',
      message: error.message,
    });
  }
});

