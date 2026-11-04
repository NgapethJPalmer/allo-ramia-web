const express = require('express');
const cors = require('cors');
const multer = require('multer');
const OpenAI = require('openai');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// Servir les fichiers statiques du dossier web
app.use(express.static('web'));

// Configuration de Multer pour stocker l'image en mémoire vive
const upload = multer({ storage: multer.memoryStorage() });

// Initialisation d'OpenAI
const openai = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

// Route API pour l'analyse de l'ordonnance par GPT-4o Vision
app.post('/api/analyze-prescription', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'Aucun fichier d\'ordonnance fourni.' });
    }

    // Convertir l'image buffer en base64 pour l'envoyer à l'API Vision
    const base64Image = req.file.buffer.toString('base64');
    const mimeType = req.file.mimetype;

    console.log("Analyse d'une ordonnance en cours par l'IA GPT-4o...");

    const response = await openai.chat.completions.create({
      model: "gpt-4o",
      messages: [
        {
          role: "user",
          content: [
            { 
              type: "text", 
              text: "Analyse cette ordonnance médicale manuscrite. Extrais uniquement la liste des noms de médicaments et leurs dosages sous forme de format JSON strict avec la clé 'medicaments' contenant un tableau de chaînes de caractères (exemple : {\"medicaments\": [\"Fenostil\", \"Dynamogen\"]})." 
            },
            {
              image_url: {
                url: `data:${mimeType};base64,${base64Image}`
              },
              type: "image_url"
            }
          ]
        }
      ],
      response_format: { type: "json_object" }
    });

    const result = JSON.parse(response.choices[0].message.content);
    console.log("Médicaments détectés par GPT-4o :", result);
    
    res.json(result);
  } catch (error) {
    console.error("Erreur technique lors de l'analyse :", error);

    // 1. Détection spécifique du manque de crédits OpenAI (429 / Quota)
    if (error.status === 429 || error.code === 'credit_balance_exhausted' || error.type === 'insufficient_quota') {
      return res.status(402).json({ 
        error: "Solde OpenAI épuisé. Veuillez recharger votre compte sur https://platform.openai.com/settings/organization/billing pour activer l'analyse IA." 
      });
    }

    // 2. Gestion propre de l'erreur 500 pour toute autre défaillance
    return res.status(500).json({ 
      error: "Erreur interne du serveur lors de la lecture de l'ordonnance. Veuillez réessayer plus tard." 
    });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Serveur Allo Ramia démarré sur http://localhost:${PORT}`);
});
