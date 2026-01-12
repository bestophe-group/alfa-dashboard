#!/usr/bin/env node
/**
 * Wrapper CLI pour appeler Claude Code CLI ou Cursor Agent comme LLM
 * Usage: node llm-cli-wrapper.js <provider> <prompt> [model]
 * 
 * Providers: claude-code, cursor-agent
 */

const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

const PROVIDER = process.argv[2] || 'claude-code';
const PROMPT = process.argv[3] || '';
const MODEL = process.argv[4] || 'claude-3-haiku';

if (!PROMPT) {
  console.error('Usage: node llm-cli-wrapper.js <provider> <prompt> [model]');
  process.exit(1);
}

// Créer un fichier temporaire avec le prompt
const tempFile = path.join(__dirname, `.prompt-${Date.now()}.txt`);
fs.writeFileSync(tempFile, PROMPT);

try {
  let response;
  
  if (PROVIDER === 'claude-code') {
    // Essayer d'appeler le VRAI Claude Code CLI
    let cliFound = false;
    let cliResult = null;
    
    // Tentative 1: Commande directe "claude-code"
    try {
      cliResult = execSync(`claude-code chat --prompt "${PROMPT.replace(/"/g, '\\"')}" --model "${MODEL}"`, {
        encoding: 'utf8',
        maxBuffer: 10 * 1024 * 1024,
        timeout: 30000,
        stdio: ['pipe', 'pipe', 'pipe']
      });
      cliFound = true;
    } catch (e) {
      // CLI non trouvé ou erreur
    }
    
    // Tentative 2: Via Ollama (fallback gratuit)
    if (!cliFound) {
      try {
        const ollamaModel = MODEL.includes('haiku') ? 'llama2' : 'llama2:13b';
        cliResult = execSync(`ollama run ${ollamaModel} "${PROMPT.replace(/"/g, '\\"')}"`, {
          encoding: 'utf8',
          maxBuffer: 10 * 1024 * 1024,
          timeout: 60000,
          stdio: ['pipe', 'pipe', 'pipe']
        });
        cliFound = true;
        MODEL = ollamaModel; // Utiliser le modèle Ollama réel
      } catch (e) {
        // Ollama non disponible
      }
    }
    
    if (cliFound && cliResult) {
      // VRAIE réponse CLI
      response = {
        response: cliResult.trim(),
        model: MODEL,
        provider: PROVIDER,
        tokens_used: Math.floor(PROMPT.length / 4) + Math.floor(cliResult.length / 4),
        source: 'real-cli'
      };
    } else {
      // FALLBACK: Mock (si aucun CLI disponible)
      response = {
        response: `[MOCK - CLI non disponible] Réponse simulée pour: ${PROMPT.substring(0, 50)}...\n\n⚠️ Pour utiliser un vrai CLI, installez:\n- Claude Code CLI: https://claude.ai/code\n- Ollama: https://ollama.ai (gratuit, local)`,
        model: MODEL,
        provider: PROVIDER,
        tokens_used: Math.floor(PROMPT.length / 4),
        source: 'mock-fallback',
        warning: 'Aucun CLI disponible. Installez Claude Code CLI ou Ollama.'
      };
    }
    
  } else if (PROVIDER === 'cursor-agent') {
    // Essayer d'appeler le VRAI Cursor Agent
    let cliFound = false;
    let cliResult = null;
    
    // Tentative 1: Commande directe "cursor-agent"
    try {
      cliResult = execSync(`cursor-agent chat --prompt "${PROMPT.replace(/"/g, '\\"')}"`, {
        encoding: 'utf8',
        maxBuffer: 10 * 1024 * 1024,
        timeout: 60000,
        stdio: ['pipe', 'pipe', 'pipe']
      });
      cliFound = true;
    } catch (e) {
      // CLI non trouvé
    }
    
    // Tentative 2: Via Ollama (fallback)
    if (!cliFound) {
      try {
        const ollamaModel = MODEL.includes('sonnet') ? 'llama2:13b' : 'llama2';
        cliResult = execSync(`ollama run ${ollamaModel} "${PROMPT.replace(/"/g, '\\"')}"`, {
          encoding: 'utf8',
          maxBuffer: 10 * 1024 * 1024,
          timeout: 60000,
          stdio: ['pipe', 'pipe', 'pipe']
        });
        cliFound = true;
        MODEL = ollamaModel;
      } catch (e) {
        // Ollama non disponible
      }
    }
    
    if (cliFound && cliResult) {
      // VRAIE réponse CLI
      response = {
        response: cliResult.trim(),
        model: MODEL,
        provider: PROVIDER,
        tokens_used: Math.floor(PROMPT.length / 4) + Math.floor(cliResult.length / 4),
        source: 'real-cli'
      };
    } else {
      // FALLBACK: Mock
      response = {
        response: `[MOCK - CLI non disponible] Réponse simulée pour: ${PROMPT.substring(0, 50)}...\n\n⚠️ Pour utiliser un vrai CLI, installez:\n- Cursor Agent\n- Ollama: https://ollama.ai (gratuit, local)`,
        model: MODEL,
        provider: PROVIDER,
        tokens_used: Math.floor(PROMPT.length / 4),
        source: 'mock-fallback',
        warning: 'Aucun CLI disponible. Installez Cursor Agent ou Ollama.'
      };
    }
    
  } else {
    throw new Error(`Provider inconnu: ${PROVIDER}. Utilisez 'claude-code' ou 'cursor-agent'`);
  }
  
  // Retourner en JSON
  console.log(JSON.stringify(response));
  
} catch (error) {
  console.error(JSON.stringify({
    error: error.message,
    provider: PROVIDER,
    prompt: PROMPT.substring(0, 100)
  }));
  process.exit(1);
} finally {
  // Nettoyer
  if (fs.existsSync(tempFile)) {
    fs.unlinkSync(tempFile);
  }
}
