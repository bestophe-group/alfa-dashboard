#!/bin/bash
# Script pour corriger le node "Respond to Webhook" dans le workflow iana-router
# Utilise psql avec une fonction PL/pgSQL

docker exec alfa-postgres psql -U alfa -d n8n << 'EOSQL'
-- Fonction pour mettre à jour le node "respond"
CREATE OR REPLACE FUNCTION fix_respond_node()
RETURNS VOID AS $$
DECLARE
  workflow_nodes JSONB;
  updated_nodes JSONB := '[]'::JSONB;
  node_item JSONB;
  respond_node JSONB;
BEGIN
  -- Récupérer les nodes
  SELECT nodes INTO workflow_nodes FROM workflow_entity WHERE id = 'Fowjj0lqqwb1Abbi';
  
  -- Parcourir et mettre à jour
  FOR node_item IN SELECT * FROM jsonb_array_elements(workflow_nodes)
  LOOP
    IF node_item->>'id' = 'respond' THEN
      -- Créer le node mis à jour avec les paramètres
      respond_node := jsonb_set(
        node_item,
        '{parameters}',
        '{"respondWith":"json","responseBody":"={{ JSON.stringify($json) }}"}'::JSONB
      );
      updated_nodes := updated_nodes || respond_node;
    ELSE
      updated_nodes := updated_nodes || node_item;
    END IF;
  END LOOP;
  
  -- Mettre à jour
  UPDATE workflow_entity SET nodes = updated_nodes WHERE id = 'Fowjj0lqqwb1Abbi';
  
  RAISE NOTICE 'Node "respond" updated successfully';
END;
$$ LANGUAGE plpgsql;

-- Exécuter la fonction
SELECT fix_respond_node();

-- Vérifier
SELECT 
  (SELECT value FROM jsonb_array_elements((SELECT nodes FROM workflow_entity WHERE id = 'Fowjj0lqqwb1Abbi')::JSONB) WHERE value->>'id' = 'respond')::JSONB->'parameters' AS respond_params;

-- Nettoyer
DROP FUNCTION fix_respond_node();
EOSQL
