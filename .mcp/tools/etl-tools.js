/**
 * ALFA MCP - ETL Tools
 * Expertise en transformation de données: fichiers, audio, vidéo, texte, images
 */

import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

export const etlTools = [
  {
    name: 'alfa_etl_video_to_text',
    description: 'Transcription vidéo vers texte (audio extraction + speech-to-text)',
    inputSchema: {
      type: 'object',
      properties: {
        video_path: { type: 'string', description: 'Chemin vers fichier vidéo' },
        output_format: { type: 'string', enum: ['txt', 'srt', 'vtt', 'json'], description: 'Format de sortie' },
        language: { type: 'string', description: 'Code langue (fr, en, es, etc.)' },
        include_timestamps: { type: 'boolean', description: 'Inclure les timestamps' },
        whisper_model: { type: 'string', enum: ['tiny', 'base', 'small', 'medium', 'large'], description: 'Modèle Whisper' },
      },
      required: ['video_path'],
    },
  },
  {
    name: 'alfa_etl_audio_to_text',
    description: 'Transcription audio vers texte via Whisper',
    inputSchema: {
      type: 'object',
      properties: {
        audio_path: { type: 'string', description: 'Chemin vers fichier audio' },
        output_format: { type: 'string', enum: ['txt', 'srt', 'vtt', 'json'] },
        language: { type: 'string', description: 'Code langue' },
        whisper_model: { type: 'string', enum: ['tiny', 'base', 'small', 'medium', 'large'] },
      },
      required: ['audio_path'],
    },
  },
  {
    name: 'alfa_etl_pdf_to_text',
    description: 'Extraction de texte depuis PDF avec OCR si nécessaire',
    inputSchema: {
      type: 'object',
      properties: {
        pdf_path: { type: 'string', description: 'Chemin vers PDF' },
        use_ocr: { type: 'boolean', description: 'Utiliser OCR pour PDFs scannés' },
        extract_images: { type: 'boolean', description: 'Extraire les images' },
        output_format: { type: 'string', enum: ['txt', 'markdown', 'json'] },
      },
      required: ['pdf_path'],
    },
  },
  {
    name: 'alfa_etl_image_to_text',
    description: 'OCR sur image: extraction de texte',
    inputSchema: {
      type: 'object',
      properties: {
        image_path: { type: 'string', description: 'Chemin vers image' },
        language: { type: 'string', description: 'Langue du texte (fra, eng, etc.)' },
        output_format: { type: 'string', enum: ['txt', 'json', 'hocr'] },
      },
      required: ['image_path'],
    },
  },
  {
    name: 'alfa_etl_csv_transform',
    description: 'Transformation CSV: mapping colonnes, filtres, agrégations',
    inputSchema: {
      type: 'object',
      properties: {
        input_csv: { type: 'string', description: 'Chemin CSV source' },
        output_csv: { type: 'string', description: 'Chemin CSV destination' },
        transformations: {
          type: 'array',
          description: 'Liste de transformations à appliquer',
          items: {
            type: 'object',
            properties: {
              type: { type: 'string', enum: ['rename', 'filter', 'map', 'aggregate', 'join'] },
              config: { type: 'object' },
            },
          },
        },
      },
      required: ['input_csv', 'transformations'],
    },
  },
  {
    name: 'alfa_etl_json_to_csv',
    description: 'Conversion JSON vers CSV avec aplatissement de structure',
    inputSchema: {
      type: 'object',
      properties: {
        json_path: { type: 'string', description: 'Chemin vers JSON' },
        output_csv: { type: 'string', description: 'Chemin CSV destination' },
        flatten: { type: 'boolean', description: 'Aplatir les objets imbriqués' },
        fields: { type: 'array', items: { type: 'string' }, description: 'Champs à extraire' },
      },
      required: ['json_path'],
    },
  },
  {
    name: 'alfa_etl_excel_to_db',
    description: 'Import Excel vers PostgreSQL avec mapping de colonnes',
    inputSchema: {
      type: 'object',
      properties: {
        excel_path: { type: 'string', description: 'Chemin vers fichier Excel' },
        sheet_name: { type: 'string', description: 'Nom de la feuille' },
        table_name: { type: 'string', description: 'Table PostgreSQL destination' },
        column_mapping: { type: 'object', description: 'Mapping colonnes Excel -> DB' },
        create_table: { type: 'boolean', description: 'Créer la table si inexistante' },
      },
      required: ['excel_path', 'table_name'],
    },
  },
  {
    name: 'alfa_etl_text_to_speech',
    description: 'Génération audio depuis texte via ElevenLabs ou autre TTS',
    inputSchema: {
      type: 'object',
      properties: {
        text: { type: 'string', description: 'Texte à synthétiser' },
        voice_id: { type: 'string', description: 'ID de voix ElevenLabs' },
        output_path: { type: 'string', description: 'Chemin fichier audio de sortie' },
        language: { type: 'string', description: 'Code langue' },
        model: { type: 'string', enum: ['elevenlabs', 'azure', 'google'], description: 'Service TTS' },
      },
      required: ['text'],
    },
  },
  {
    name: 'alfa_etl_web_to_markdown',
    description: 'Conversion page web vers Markdown propre',
    inputSchema: {
      type: 'object',
      properties: {
        url: { type: 'string', description: 'URL de la page' },
        output_path: { type: 'string', description: 'Chemin fichier Markdown' },
        remove_ads: { type: 'boolean', description: 'Supprimer publicités et scripts' },
        extract_images: { type: 'boolean', description: 'Télécharger les images' },
      },
      required: ['url'],
    },
  },
  {
    name: 'alfa_etl_batch_convert',
    description: 'Conversion par lot de fichiers (audio, vidéo, images, documents)',
    inputSchema: {
      type: 'object',
      properties: {
        source_dir: { type: 'string', description: 'Dossier source' },
        output_dir: { type: 'string', description: 'Dossier destination' },
        input_format: { type: 'string', description: 'Format source (mp4, wav, png, etc.)' },
        output_format: { type: 'string', description: 'Format cible' },
        conversion_options: { type: 'object', description: 'Options FFmpeg ou ImageMagick' },
      },
      required: ['source_dir', 'input_format', 'output_format'],
    },
  },
];

export async function executeETLTool(name, args) {
  switch (name) {
    case 'alfa_etl_video_to_text': {
      const videoPath = args.video_path;
      const audioPath = `/tmp/${path.basename(videoPath, path.extname(videoPath))}.wav`;

      // Extract audio with FFmpeg
      execSync(`ffmpeg -i "${videoPath}" -ar 16000 -ac 1 "${audioPath}" -y`);

      // Transcribe with Whisper
      const model = args.whisper_model || 'base';
      const outputFormat = args.output_format || 'txt';

      const whisperCmd = `whisper "${audioPath}" --model ${model} --output_format ${outputFormat} --language ${args.language || 'fr'}`;

      const output = execSync(whisperCmd, { encoding: 'utf8' });

      // Cleanup
      fs.unlinkSync(audioPath);

      return `Video transcribed successfully. Output: ${output}`;
    }

    case 'alfa_etl_audio_to_text': {
      const model = args.whisper_model || 'base';
      const outputFormat = args.output_format || 'txt';

      const cmd = `whisper "${args.audio_path}" --model ${model} --output_format ${outputFormat} --language ${args.language || 'fr'}`;

      const output = execSync(cmd, { encoding: 'utf8' });

      return `Audio transcribed: ${output}`;
    }

    case 'alfa_etl_pdf_to_text': {
      const pdfPath = args.pdf_path;
      const outputFormat = args.output_format || 'txt';
      const outputPath = `/tmp/${path.basename(pdfPath, '.pdf')}.${outputFormat}`;

      if (args.use_ocr) {
        // OCR with Tesseract via ocrmypdf
        execSync(`ocrmypdf --force-ocr "${pdfPath}" "${outputPath}.pdf"`);
        execSync(`pdftotext "${outputPath}.pdf" "${outputPath}"`);
      } else {
        // Simple text extraction
        execSync(`pdftotext "${pdfPath}" "${outputPath}"`);
      }

      const content = fs.readFileSync(outputPath, 'utf8');

      if (outputFormat === 'markdown') {
        // Convert to markdown format
        const markdown = content
          .split('\n\n')
          .map(para => para.trim())
          .join('\n\n');
        fs.writeFileSync(outputPath, markdown);
      }

      return `PDF extracted to: ${outputPath}`;
    }

    case 'alfa_etl_image_to_text': {
      const language = args.language || 'fra';
      const outputFormat = args.output_format || 'txt';
      const outputPath = `/tmp/${path.basename(args.image_path, path.extname(args.image_path))}.${outputFormat}`;

      execSync(`tesseract "${args.image_path}" "${outputPath.replace(`.${outputFormat}`, '')}" -l ${language} ${outputFormat === 'hocr' ? 'hocr' : ''}`);

      const content = fs.readFileSync(outputPath, 'utf8');

      return `OCR completed. Text extracted:\n${content.substring(0, 500)}...`;
    }

    case 'alfa_etl_csv_transform': {
      // Use Python pandas for complex transformations
      const pythonScript = `
import pandas as pd
import json

# Read CSV
df = pd.read_csv('${args.input_csv}')

# Apply transformations
transformations = ${JSON.stringify(args.transformations)}

for transform in transformations:
    if transform['type'] == 'rename':
        df = df.rename(columns=transform['config'])
    elif transform['type'] == 'filter':
        # Apply filter condition
        condition = transform['config']['condition']
        df = df.query(condition)
    elif transform['type'] == 'map':
        # Map column values
        col = transform['config']['column']
        mapping = transform['config']['mapping']
        df[col] = df[col].map(mapping)
    elif transform['type'] == 'aggregate':
        # Group by and aggregate
        groupby = transform['config']['groupby']
        agg = transform['config']['agg']
        df = df.groupby(groupby).agg(agg).reset_index()

# Save result
df.to_csv('${args.output_csv || '/tmp/output.csv'}', index=False)
print(f"Transformed {len(df)} rows")
`;

      fs.writeFileSync('/tmp/transform.py', pythonScript);
      const output = execSync('python3 /tmp/transform.py', { encoding: 'utf8' });

      return output;
    }

    case 'alfa_etl_json_to_csv': {
      const pythonScript = `
import pandas as pd
import json

with open('${args.json_path}', 'r') as f:
    data = json.load(f)

# Convert to DataFrame
df = pd.json_normalize(data) if ${args.flatten || false} else pd.DataFrame(data)

# Select specific fields if provided
${args.fields ? `df = df[${JSON.stringify(args.fields)}]` : ''}

# Save to CSV
df.to_csv('${args.output_csv || '/tmp/output.csv'}', index=False)
print(f"Converted {len(df)} records to CSV")
`;

      fs.writeFileSync('/tmp/json_to_csv.py', pythonScript);
      const output = execSync('python3 /tmp/json_to_csv.py', { encoding: 'utf8' });

      return output;
    }

    case 'alfa_etl_text_to_speech': {
      if (args.model === 'elevenlabs' && process.env.ELEVENLABS_API_KEY) {
        const fetch = (await import('node-fetch')).default;

        const response = await fetch(
          `https://api.elevenlabs.io/v1/text-to-speech/${args.voice_id || 'pNInz6obpgDQGcFmaJgB'}`,
          {
            method: 'POST',
            headers: {
              'Accept': 'audio/mpeg',
              'xi-api-key': process.env.ELEVENLABS_API_KEY,
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
              text: args.text,
              model_id: 'eleven_multilingual_v2',
              voice_settings: {
                stability: 0.5,
                similarity_boost: 0.75,
              },
            }),
          }
        );

        const buffer = await response.buffer();
        const outputPath = args.output_path || '/tmp/speech.mp3';

        fs.writeFileSync(outputPath, buffer);

        return `TTS generated: ${outputPath}`;
      } else {
        // Fallback to system TTS
        const outputPath = args.output_path || '/tmp/speech.wav';
        execSync(`say -o "${outputPath}" --data-format=LEF32@16000 "${args.text}"`);

        return `TTS generated: ${outputPath}`;
      }
    }

    case 'alfa_etl_web_to_markdown': {
      // Use Readability or Trafilatura
      const pythonScript = `
from trafilatura import fetch_url, extract
import markdownify

url = '${args.url}'
downloaded = fetch_url(url)
content = extract(downloaded, include_comments=False, include_tables=True)

if content:
    with open('${args.output_path || '/tmp/webpage.md'}', 'w') as f:
        f.write(content)
    print(f"Page converted to Markdown")
else:
    print("Failed to extract content")
`;

      fs.writeFileSync('/tmp/web_to_md.py', pythonScript);
      const output = execSync('python3 /tmp/web_to_md.py', { encoding: 'utf8' });

      return output;
    }

    default:
      throw new Error(`Unknown ETL tool: ${name}`);
  }
}
