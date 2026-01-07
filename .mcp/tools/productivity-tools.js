/**
 * ALFA MCP - Productivity Tools
 * Obsidian vault management and knowledge base
 */

import { execSync } from 'child_process';
import fs from 'fs';
import path from 'path';

export const productivityTools = [
  {
    name: 'alfa_obsidian_create_note',
    description: 'Créer note Obsidian avec frontmatter et liens',
    inputSchema: {
      type: 'object',
      properties: {
        vault_path: { type: 'string', description: 'Chemin vers le vault Obsidian' },
        note_title: { type: 'string', description: 'Titre de la note (devient le nom du fichier)' },
        folder: { type: 'string', description: 'Dossier dans le vault (ex: Projects/Work)' },
        content: { type: 'string', description: 'Contenu markdown de la note' },
        frontmatter: {
          type: 'object',
          description: 'Métadonnées YAML frontmatter',
          properties: {
            tags: { type: 'array', items: { type: 'string' } },
            aliases: { type: 'array', items: { type: 'string' } },
            date: { type: 'string' },
            status: { type: 'string' },
          },
        },
        links: { type: 'array', items: { type: 'string' }, description: 'Notes à lier (wikilinks)' },
      },
      required: ['vault_path', 'note_title', 'content'],
    },
  },
  {
    name: 'alfa_obsidian_search_notes',
    description: 'Rechercher dans vault Obsidian: contenu, tags, frontmatter',
    inputSchema: {
      type: 'object',
      properties: {
        vault_path: { type: 'string', description: 'Chemin vers le vault' },
        query: { type: 'string', description: 'Texte à rechercher' },
        search_type: { type: 'string', enum: ['content', 'title', 'tags', 'frontmatter'], description: 'Type de recherche' },
        tags: { type: 'array', items: { type: 'string' }, description: 'Filtrer par tags' },
        folder: { type: 'string', description: 'Limiter à un dossier' },
      },
      required: ['vault_path', 'query'],
    },
  },
  {
    name: 'alfa_obsidian_update_note',
    description: 'Modifier note Obsidian: append, prepend, replace',
    inputSchema: {
      type: 'object',
      properties: {
        vault_path: { type: 'string', description: 'Chemin vers le vault' },
        note_path: { type: 'string', description: 'Chemin relatif de la note dans le vault' },
        action: { type: 'string', enum: ['append', 'prepend', 'replace'], description: 'Type de modification' },
        content: { type: 'string', description: 'Contenu à ajouter/remplacer' },
        update_frontmatter: {
          type: 'object',
          description: 'Mettre à jour le frontmatter',
        },
      },
      required: ['vault_path', 'note_path', 'action', 'content'],
    },
  },
  {
    name: 'alfa_obsidian_graph_analysis',
    description: 'Analyser graphe de connaissances: liens, backlinks, orphelins',
    inputSchema: {
      type: 'object',
      properties: {
        vault_path: { type: 'string', description: 'Chemin vers le vault' },
        analysis_type: {
          type: 'string',
          enum: ['backlinks', 'forward_links', 'orphans', 'hub_notes', 'clusters'],
          description: 'Type d\'analyse',
        },
        note_path: { type: 'string', description: 'Note spécifique à analyser (optionnel)' },
        min_links: { type: 'number', description: 'Minimum de liens pour hub notes' },
      },
      required: ['vault_path', 'analysis_type'],
    },
  },
  {
    name: 'alfa_obsidian_daily_note',
    description: 'Créer/accéder daily note avec template',
    inputSchema: {
      type: 'object',
      properties: {
        vault_path: { type: 'string', description: 'Chemin vers le vault' },
        date: { type: 'string', description: 'Date (YYYY-MM-DD, default: today)' },
        daily_folder: { type: 'string', description: 'Dossier des daily notes (default: Daily Notes)' },
        template: { type: 'string', description: 'Contenu template de la daily note' },
        auto_create: { type: 'boolean', description: 'Créer si n\'existe pas (default: true)' },
      },
      required: ['vault_path'],
    },
  },
  {
    name: 'alfa_obsidian_export_vault',
    description: 'Exporter vault ou dossier: PDF, HTML, markdown consolidé',
    inputSchema: {
      type: 'object',
      properties: {
        vault_path: { type: 'string', description: 'Chemin vers le vault' },
        export_format: { type: 'string', enum: ['pdf', 'html', 'markdown', 'json'], description: 'Format d\'export' },
        output_path: { type: 'string', description: 'Chemin de sortie' },
        folder: { type: 'string', description: 'Dossier spécifique à exporter' },
        include_attachments: { type: 'boolean', description: 'Inclure images/fichiers' },
        resolve_links: { type: 'boolean', description: 'Convertir wikilinks en liens standards' },
      },
      required: ['vault_path', 'export_format', 'output_path'],
    },
  },
  {
    name: 'alfa_obsidian_template_apply',
    description: 'Appliquer template Obsidian avec variables',
    inputSchema: {
      type: 'object',
      properties: {
        vault_path: { type: 'string', description: 'Chemin vers le vault' },
        template_name: { type: 'string', description: 'Nom du template (dans Templates/)' },
        output_note_title: { type: 'string', description: 'Titre de la note créée' },
        output_folder: { type: 'string', description: 'Dossier de destination' },
        variables: {
          type: 'object',
          description: 'Variables à remplacer dans le template {{variable}}',
        },
      },
      required: ['vault_path', 'template_name', 'output_note_title'],
    },
  },
  {
    name: 'alfa_obsidian_sync_status',
    description: 'Vérifier status sync Obsidian (Sync ou Git)',
    inputSchema: {
      type: 'object',
      properties: {
        vault_path: { type: 'string', description: 'Chemin vers le vault' },
        sync_method: { type: 'string', enum: ['obsidian_sync', 'git'], description: 'Méthode de sync' },
      },
      required: ['vault_path'],
    },
  },
];

export async function executeProductivityTool(name, args) {
  switch (name) {
    case 'alfa_obsidian_create_note': {
      const vaultPath = args.vault_path;
      const folderPath = args.folder ? path.join(vaultPath, args.folder) : vaultPath;
      const fileName = `${args.note_title.replace(/[/\\?%*:|"<>]/g, '-')}.md`;
      const filePath = path.join(folderPath, fileName);

      // Create folder if doesn't exist
      if (!fs.existsSync(folderPath)) {
        fs.mkdirSync(folderPath, { recursive: true });
      }

      // Build frontmatter
      let frontmatter = '';
      if (args.frontmatter) {
        frontmatter = '---\n';
        for (const [key, value] of Object.entries(args.frontmatter)) {
          if (Array.isArray(value)) {
            frontmatter += `${key}: [${value.map(v => `"${v}"`).join(', ')}]\n`;
          } else {
            frontmatter += `${key}: ${value}\n`;
          }
        }
        frontmatter += '---\n\n';
      }

      // Build content with links
      let content = args.content;
      if (args.links && args.links.length > 0) {
        content += '\n\n## Links\n';
        args.links.forEach(link => {
          content += `- [[${link}]]\n`;
        });
      }

      // Write file
      const fullContent = frontmatter + content;
      fs.writeFileSync(filePath, fullContent, 'utf8');

      return JSON.stringify({
        success: true,
        file_path: filePath,
        note_title: args.note_title,
        obsidian_uri: `obsidian://open?vault=${encodeURIComponent(path.basename(vaultPath))}&file=${encodeURIComponent(args.folder ? `${args.folder}/${fileName}` : fileName)}`,
      }, null, 2);
    }

    case 'alfa_obsidian_search_notes': {
      const vaultPath = args.vault_path;
      const searchFolder = args.folder ? path.join(vaultPath, args.folder) : vaultPath;

      // Use grep for search
      let grepCmd = '';
      switch (args.search_type || 'content') {
        case 'content':
          grepCmd = `grep -r -i -l "${args.query}" "${searchFolder}"`;
          break;
        case 'title':
          grepCmd = `find "${searchFolder}" -type f -name "*${args.query}*.md"`;
          break;
        case 'tags':
          grepCmd = `grep -r -l "tags:.*${args.query}" "${searchFolder}"`;
          break;
        case 'frontmatter':
          grepCmd = `grep -r -l "${args.query}" "${searchFolder}"`;
          break;
      }

      const output = execSync(grepCmd, { encoding: 'utf8', shell: '/bin/bash' });
      const files = output.split('\n').filter(f => f.endsWith('.md'));

      return JSON.stringify({
        query: args.query,
        search_type: args.search_type || 'content',
        results_count: files.length,
        files: files.map(f => ({
          path: f,
          relative_path: path.relative(vaultPath, f),
          obsidian_uri: `obsidian://open?vault=${encodeURIComponent(path.basename(vaultPath))}&file=${encodeURIComponent(path.relative(vaultPath, f))}`,
        })),
      }, null, 2);
    }

    case 'alfa_obsidian_update_note': {
      const filePath = path.join(args.vault_path, args.note_path);

      if (!fs.existsSync(filePath)) {
        throw new Error(`Note not found: ${filePath}`);
      }

      let existingContent = fs.readFileSync(filePath, 'utf8');

      switch (args.action) {
        case 'append':
          existingContent += '\n' + args.content;
          break;
        case 'prepend':
          // Insert after frontmatter if exists
          const frontmatterMatch = existingContent.match(/^---\n[\s\S]*?\n---\n/);
          if (frontmatterMatch) {
            existingContent = frontmatterMatch[0] + '\n' + args.content + existingContent.slice(frontmatterMatch[0].length);
          } else {
            existingContent = args.content + '\n' + existingContent;
          }
          break;
        case 'replace':
          // Keep frontmatter if exists
          const fm = existingContent.match(/^---\n[\s\S]*?\n---\n/);
          existingContent = (fm ? fm[0] : '') + args.content;
          break;
      }

      // Update frontmatter if provided
      if (args.update_frontmatter) {
        const fmMatch = existingContent.match(/^---\n([\s\S]*?)\n---\n/);
        if (fmMatch) {
          let fmContent = fmMatch[1];
          for (const [key, value] of Object.entries(args.update_frontmatter)) {
            const regex = new RegExp(`^${key}:.*$`, 'm');
            const newLine = Array.isArray(value)
              ? `${key}: [${value.map(v => `"${v}"`).join(', ')}]`
              : `${key}: ${value}`;
            if (regex.test(fmContent)) {
              fmContent = fmContent.replace(regex, newLine);
            } else {
              fmContent += `\n${newLine}`;
            }
          }
          existingContent = existingContent.replace(/^---\n[\s\S]*?\n---\n/, `---\n${fmContent}\n---\n`);
        }
      }

      fs.writeFileSync(filePath, existingContent, 'utf8');

      return JSON.stringify({
        success: true,
        file_path: filePath,
        action: args.action,
      }, null, 2);
    }

    case 'alfa_obsidian_graph_analysis': {
      const vaultPath = args.vault_path;
      const results = {};

      switch (args.analysis_type) {
        case 'orphans': {
          // Find notes with no links (incoming or outgoing)
          const allFiles = execSync(`find "${vaultPath}" -type f -name "*.md"`, { encoding: 'utf8' })
            .split('\n').filter(Boolean);

          const orphans = [];
          for (const file of allFiles) {
            const content = fs.readFileSync(file, 'utf8');
            const hasOutgoing = /\[\[.*?\]\]/.test(content);
            const fileName = path.basename(file, '.md');
            const hasIncoming = allFiles.some(f => {
              if (f === file) return false;
              const c = fs.readFileSync(f, 'utf8');
              return c.includes(`[[${fileName}]]`);
            });

            if (!hasOutgoing && !hasIncoming) {
              orphans.push(path.relative(vaultPath, file));
            }
          }
          results.orphans = orphans;
          break;
        }

        case 'backlinks': {
          // Find all notes linking to the target note
          const notePath = args.note_path;
          const noteName = path.basename(notePath, '.md');
          const backlinks = execSync(
            `grep -r -l "\\[\\[${noteName}\\]\\]" "${vaultPath}"`,
            { encoding: 'utf8', shell: '/bin/bash' }
          ).split('\n').filter(f => f.endsWith('.md'));

          results.backlinks = backlinks.map(f => path.relative(vaultPath, f));
          break;
        }

        case 'hub_notes': {
          // Find notes with many outgoing links
          const allFiles = execSync(`find "${vaultPath}" -type f -name "*.md"`, { encoding: 'utf8' })
            .split('\n').filter(Boolean);

          const hubs = [];
          for (const file of allFiles) {
            const content = fs.readFileSync(file, 'utf8');
            const links = content.match(/\[\[.*?\]\]/g) || [];
            if (links.length >= (args.min_links || 5)) {
              hubs.push({
                file: path.relative(vaultPath, file),
                link_count: links.length,
              });
            }
          }
          results.hub_notes = hubs.sort((a, b) => b.link_count - a.link_count);
          break;
        }
      }

      return JSON.stringify(results, null, 2);
    }

    case 'alfa_obsidian_daily_note': {
      const vaultPath = args.vault_path;
      const dailyFolder = args.daily_folder || 'Daily Notes';
      const date = args.date || new Date().toISOString().split('T')[0];
      const fileName = `${date}.md`;
      const folderPath = path.join(vaultPath, dailyFolder);
      const filePath = path.join(folderPath, fileName);

      if (!fs.existsSync(folderPath)) {
        fs.mkdirSync(folderPath, { recursive: true });
      }

      if (!fs.existsSync(filePath) && args.auto_create !== false) {
        const template = args.template || `# ${date}\n\n## Tasks\n\n- [ ] \n\n## Notes\n\n`;
        fs.writeFileSync(filePath, template, 'utf8');
      }

      return JSON.stringify({
        daily_note_path: filePath,
        date,
        exists: fs.existsSync(filePath),
        obsidian_uri: `obsidian://open?vault=${encodeURIComponent(path.basename(vaultPath))}&file=${encodeURIComponent(`${dailyFolder}/${fileName}`)}`,
      }, null, 2);
    }

    case 'alfa_obsidian_export_vault': {
      const vaultPath = args.vault_path;
      const exportFolder = args.folder ? path.join(vaultPath, args.folder) : vaultPath;

      switch (args.export_format) {
        case 'markdown': {
          // Consolidate all markdown files
          const files = execSync(`find "${exportFolder}" -type f -name "*.md"`, { encoding: 'utf8' })
            .split('\n').filter(Boolean);

          let consolidated = '';
          for (const file of files) {
            const content = fs.readFileSync(file, 'utf8');
            consolidated += `\n\n# ${path.basename(file, '.md')}\n\n${content}`;
          }

          fs.writeFileSync(args.output_path, consolidated, 'utf8');
          break;
        }

        case 'json': {
          // Export as structured JSON
          const files = execSync(`find "${exportFolder}" -type f -name "*.md"`, { encoding: 'utf8' })
            .split('\n').filter(Boolean);

          const vault = {
            notes: files.map(file => ({
              path: path.relative(vaultPath, file),
              title: path.basename(file, '.md'),
              content: fs.readFileSync(file, 'utf8'),
            })),
          };

          fs.writeFileSync(args.output_path, JSON.stringify(vault, null, 2), 'utf8');
          break;
        }

        default:
          return JSON.stringify({
            note: `Export to ${args.export_format} requires Pandoc or similar tool`,
            command: `pandoc "${exportFolder}/*.md" -o "${args.output_path}"`,
          }, null, 2);
      }

      return JSON.stringify({
        success: true,
        output_path: args.output_path,
        format: args.export_format,
      }, null, 2);
    }

    case 'alfa_obsidian_sync_status': {
      const vaultPath = args.vault_path;

      if (args.sync_method === 'git') {
        const status = execSync('git status --porcelain', {
          cwd: vaultPath,
          encoding: 'utf8',
        });

        const unpushed = execSync('git log @{u}.. --oneline', {
          cwd: vaultPath,
          encoding: 'utf8',
        });

        return JSON.stringify({
          sync_method: 'git',
          has_changes: status.length > 0,
          unpushed_commits: unpushed.split('\n').filter(Boolean).length,
          status_details: status,
        }, null, 2);
      }

      return JSON.stringify({
        sync_method: args.sync_method || 'unknown',
        note: 'Obsidian Sync status not available via API',
        recommendation: 'Check Obsidian app for sync status',
      }, null, 2);
    }

    default:
      throw new Error(`Unknown productivity tool: ${name}`);
  }
}
