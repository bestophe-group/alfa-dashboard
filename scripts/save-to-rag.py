#!/usr/bin/env python3
"""
Helper script pour enregistrer automatiquement des données dans le RAG
Usage depuis Python ou scripts
"""
import json
import urllib.request
import urllib.error
import sys

def save_to_rag(title, content, category='knowledge', metadata=None, user_id='arnaud', priority='P2'):
    """
    Enregistrer des données dans le RAG via workflow n8n
    
    Args:
        title: Titre du document
        content: Contenu à enregistrer
        category: Catégorie (knowledge, credentials, config, conversation, etc.)
        metadata: Dictionnaire de métadonnées additionnelles
        user_id: ID utilisateur
        priority: Priorité (P1, P2, P3)
    
    Returns:
        dict: Réponse du workflow (success, document_id, etc.)
    """
    url = 'http://localhost:5678/webhook/rag/auto-save'
    
    payload = {
        'action': 'save',
        'data': {
            'title': title,
            'content': content,
            'category': category,
            'metadata': metadata or {},
            'priority': priority
        },
        'user_id': user_id
    }
    
    try:
        req = urllib.request.Request(
            url,
            data=json.dumps(payload).encode('utf-8'),
            headers={'Content-Type': 'application/json'},
            method='POST'
        )
        
        with urllib.request.urlopen(req, timeout=10) as response:
            result = json.loads(response.read().decode('utf-8'))
            return result
    except urllib.error.HTTPError as e:
        error_body = e.read().decode('utf-8')
        try:
            error_data = json.loads(error_body)
            return {'success': False, 'error': error_data.get('message', 'Unknown error')}
        except:
            return {'success': False, 'error': error_body[:100]}
    except Exception as e:
        return {'success': False, 'error': str(e)}

if __name__ == '__main__':
    # Exemple d'utilisation
    if len(sys.argv) < 3:
        print("Usage: python3 save-to-rag.py <title> <content> [category]")
        sys.exit(1)
    
    title = sys.argv[1]
    content = sys.argv[2]
    category = sys.argv[3] if len(sys.argv) > 3 else 'knowledge'
    
    result = save_to_rag(title, content, category=category)
    
    if result.get('success'):
        print(f"✅ Document enregistré: {result.get('data', {}).get('document_id')}")
    else:
        print(f"❌ Erreur: {result.get('error', 'Unknown error')}")
        sys.exit(1)
