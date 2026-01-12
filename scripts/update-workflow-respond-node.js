#!/usr/bin/env node
// Script pour mettre à jour le node "Respond to Webhook" dans le workflow iana-router
const { Client } = require('pg');

const client = new Client({
  host: process.env.POSTGRES_HOST || 'localhost',
  port: process.env.POSTGRES_PORT || 5432,
  database: process.env.POSTGRES_DB || 'n8n',
  user: process.env.POSTGRES_USER || 'alfa',
  password: process.env.POSTGRES_PASSWORD || 'alfapass123',
});

async function updateWorkflow() {
  try {
    await client.connect();
    
    // Récupérer le workflow
    const result = await client.query(
      "SELECT nodes FROM workflow_entity WHERE id = 'Fowjj0lqqwb1Abbi'"
    );
    
    if (result.rows.length === 0) {
      console.error('Workflow not found');
      process.exit(1);
    }
    
    const nodes = result.rows[0].nodes;
    
    // Trouver et mettre à jour le node "respond"
    const updatedNodes = nodes.map(node => {
      if (node.id === 'respond') {
        return {
          ...node,
          parameters: {
            respondWith: 'json',
            responseBody: '={{ JSON.stringify($json) }}'
          }
        };
      }
      return node;
    });
    
    // Mettre à jour dans la base de données
    await client.query(
      "UPDATE workflow_entity SET nodes = $1::jsonb WHERE id = 'Fowjj0lqqwb1Abbi'",
      [JSON.stringify(updatedNodes)]
    );
    
    console.log('✅ Workflow updated successfully');
    await client.end();
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

updateWorkflow();
