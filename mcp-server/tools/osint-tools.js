/**
 * ALFA MCP - OSINT Tools
 * Expertise en recherche OSINT: entreprises, personnes, dark web, patrimoine, réseaux sociaux
 */

import { execSync } from 'child_process';
import fetch from 'node-fetch';

export const osintTools = [
  {
    name: 'alfa_osint_company_research',
    description: 'Recherche OSINT complète sur une entreprise: SIREN, dirigeants, patrimoine, actionnaires',
    inputSchema: {
      type: 'object',
      properties: {
        company_name: { type: 'string', description: 'Nom de l\'entreprise' },
        siren: { type: 'string', description: 'Numéro SIREN (optionnel)' },
        search_depth: { type: 'string', enum: ['basic', 'deep', 'extensive'], description: 'Profondeur de recherche' },
        include_subsidiaries: { type: 'boolean', description: 'Inclure les filiales' },
      },
      required: ['company_name'],
    },
  },
  {
    name: 'alfa_osint_person_research',
    description: 'Recherche OSINT sur une personne: réseaux sociaux, entreprises, patrimoine, dark web mentions',
    inputSchema: {
      type: 'object',
      properties: {
        full_name: { type: 'string', description: 'Nom complet' },
        company: { type: 'string', description: 'Entreprise associée (optionnel)' },
        location: { type: 'string', description: 'Localisation (optionnel)' },
        search_social_media: { type: 'boolean', description: 'Rechercher sur réseaux sociaux' },
        search_dark_web: { type: 'boolean', description: 'Rechercher sur dark web (emails leaks)' },
      },
      required: ['full_name'],
    },
  },
  {
    name: 'alfa_osint_dark_web_search',
    description: 'Recherche sur le dark web: data leaks, mentions d\'email, compromissions',
    inputSchema: {
      type: 'object',
      properties: {
        search_type: { type: 'string', enum: ['email', 'domain', 'username'], description: 'Type de recherche' },
        query: { type: 'string', description: 'Email, domaine ou username à rechercher' },
        sources: {
          type: 'array',
          items: { type: 'string' },
          description: 'Sources: haveibeenpwned, dehashed, leakcheck, intelx',
        },
      },
      required: ['search_type', 'query'],
    },
  },
  {
    name: 'alfa_osint_social_media_scrape',
    description: 'Scraping de profils réseaux sociaux: LinkedIn, Twitter, Facebook, Instagram',
    inputSchema: {
      type: 'object',
      properties: {
        platform: { type: 'string', enum: ['linkedin', 'twitter', 'facebook', 'instagram', 'all'] },
        target: { type: 'string', description: 'Nom ou handle à rechercher' },
        extract_contacts: { type: 'boolean', description: 'Extraire emails et téléphones' },
        extract_connections: { type: 'boolean', description: 'Extraire réseau/connexions' },
      },
      required: ['platform', 'target'],
    },
  },
  {
    name: 'alfa_osint_domain_reconnaissance',
    description: 'Reconnaissance complète d\'un domaine: DNS, subdomains, technologies, emails, ports',
    inputSchema: {
      type: 'object',
      properties: {
        domain: { type: 'string', description: 'Domaine à analyser' },
        scan_subdomains: { type: 'boolean', description: 'Scanner les sous-domaines' },
        scan_ports: { type: 'boolean', description: 'Scanner les ports ouverts' },
        extract_emails: { type: 'boolean', description: 'Extraire les emails publics' },
        detect_technologies: { type: 'boolean', description: 'Détecter les technologies utilisées' },
      },
      required: ['domain'],
    },
  },
  {
    name: 'alfa_osint_executive_team_mapping',
    description: 'Cartographie complète de l\'équipe dirigeante: organigramme, parcours, connexions',
    inputSchema: {
      type: 'object',
      properties: {
        company_name: { type: 'string', description: 'Nom de l\'entreprise' },
        include_board: { type: 'boolean', description: 'Inclure conseil d\'administration' },
        include_history: { type: 'boolean', description: 'Inclure parcours professionnel' },
        include_network: { type: 'boolean', description: 'Inclure réseau professionnel' },
      },
      required: ['company_name'],
    },
  },
  {
    name: 'alfa_osint_financial_research',
    description: 'Recherche financière: bilans, actionnaires, participations, patrimoine immobilier',
    inputSchema: {
      type: 'object',
      properties: {
        entity_type: { type: 'string', enum: ['company', 'person'] },
        entity_name: { type: 'string', description: 'Nom de l\'entité' },
        include_real_estate: { type: 'boolean', description: 'Inclure patrimoine immobilier' },
        include_investments: { type: 'boolean', description: 'Inclure participations' },
        include_court_records: { type: 'boolean', description: 'Inclure dossiers judiciaires' },
      },
      required: ['entity_type', 'entity_name'],
    },
  },
  {
    name: 'alfa_osint_data_breach_monitor',
    description: 'Surveillance continue des data breaches pour un domaine ou liste d\'emails',
    inputSchema: {
      type: 'object',
      properties: {
        domain: { type: 'string', description: 'Domaine à surveiller' },
        email_list: { type: 'array', items: { type: 'string' }, description: 'Liste d\'emails à surveiller' },
        alert_webhook: { type: 'string', description: 'Webhook n8n pour alertes' },
        check_frequency: { type: 'string', enum: ['daily', 'weekly', 'monthly'] },
      },
    },
  },
];

export async function executeOSINTTool(name, args) {
  switch (name) {
    case 'alfa_osint_company_research': {
      const results = {
        company: args.company_name,
        timestamp: new Date().toISOString(),
        sources: [],
      };

      // Pappers API (registre entreprises FR)
      if (process.env.PAPPERS_API_KEY) {
        try {
          const response = await fetch(
            `https://api.pappers.fr/v2/entreprise?api_token=${process.env.PAPPERS_API_KEY}&nom_entreprise=${encodeURIComponent(args.company_name)}`
          );
          const data = await response.json();
          results.sources.push({
            source: 'Pappers',
            data: {
              siren: data.siren,
              siret: data.siege?.siret,
              dirigeants: data.representants,
              capital: data.capital,
              effectif: data.effectif,
              bilans: data.finances,
            },
          });
        } catch (error) {
          results.sources.push({ source: 'Pappers', error: error.message });
        }
      }

      // OpenCorporates (international)
      try {
        const response = await fetch(
          `https://api.opencorporates.com/v0.4/companies/search?q=${encodeURIComponent(args.company_name)}&jurisdiction_code=fr`
        );
        const data = await response.json();
        results.sources.push({
          source: 'OpenCorporates',
          data: data.results?.companies?.slice(0, 5),
        });
      } catch (error) {
        results.sources.push({ source: 'OpenCorporates', error: error.message });
      }

      // Infogreffe (RCS France)
      results.sources.push({
        source: 'Infogreffe',
        url: `https://www.infogreffe.fr/recherche-siret-entreprise/chercher-dirigeant-entreprise.html?nom=${encodeURIComponent(args.company_name)}`,
        note: 'Manual verification required',
      });

      // Societe.com
      results.sources.push({
        source: 'Societe.com',
        url: `https://www.societe.com/cgi-bin/search?champs=${encodeURIComponent(args.company_name)}`,
        note: 'Manual verification required',
      });

      return JSON.stringify(results, null, 2);
    }

    case 'alfa_osint_person_research': {
      const results = {
        person: args.full_name,
        timestamp: new Date().toISOString(),
        findings: [],
      };

      // LinkedIn search (via Google dorking)
      results.findings.push({
        source: 'LinkedIn',
        search_url: `https://www.google.com/search?q=site:linkedin.com/in "${args.full_name}" ${args.company || ''}`,
        method: 'Google Dork',
      });

      // Twitter/X search
      results.findings.push({
        source: 'Twitter',
        search_url: `https://twitter.com/search?q="${args.full_name}" ${args.company || ''}&f=user`,
      });

      // Have I Been Pwned (si email fourni)
      if (args.full_name.includes('@')) {
        try {
          const response = await fetch(
            `https://haveibeenpwned.com/api/v3/breachedaccount/${encodeURIComponent(args.full_name)}`,
            {
              headers: { 'User-Agent': 'ALFA-OSINT-Tool' },
            }
          );

          if (response.ok) {
            const breaches = await response.json();
            results.findings.push({
              source: 'HaveIBeenPwned',
              breaches: breaches.length,
              data: breaches.map(b => ({ name: b.Name, date: b.BreachDate })),
            });
          }
        } catch (error) {
          results.findings.push({ source: 'HaveIBeenPwned', error: error.message });
        }
      }

      // Google dorking pour mentions publiques
      results.findings.push({
        source: 'Google Search',
        search_url: `https://www.google.com/search?q="${args.full_name}" ${args.company || ''} ${args.location || ''}`,
      });

      return JSON.stringify(results, null, 2);
    }

    case 'alfa_osint_dark_web_search': {
      const results = {
        query: args.query,
        type: args.search_type,
        timestamp: new Date().toISOString(),
        sources_checked: [],
      };

      // Have I Been Pwned
      if (args.search_type === 'email') {
        try {
          const response = await fetch(
            `https://haveibeenpwned.com/api/v3/breachedaccount/${encodeURIComponent(args.query)}`,
            { headers: { 'User-Agent': 'ALFA-OSINT-Tool' } }
          );

          if (response.ok) {
            const breaches = await response.json();
            results.sources_checked.push({
              source: 'HaveIBeenPwned',
              found: true,
              breaches_count: breaches.length,
              breaches: breaches.map(b => ({
                name: b.Name,
                date: b.BreachDate,
                compromised_data: b.DataClasses,
              })),
            });
          } else {
            results.sources_checked.push({
              source: 'HaveIBeenPwned',
              found: false,
            });
          }
        } catch (error) {
          results.sources_checked.push({
            source: 'HaveIBeenPwned',
            error: error.message,
          });
        }
      }

      // DeHashed (requires API key)
      if (process.env.DEHASHED_API_KEY) {
        try {
          const auth = Buffer.from(`${process.env.DEHASHED_EMAIL}:${process.env.DEHASHED_API_KEY}`).toString('base64');
          const response = await fetch(
            `https://api.dehashed.com/search?query=${args.search_type}:${encodeURIComponent(args.query)}`,
            {
              headers: {
                'Authorization': `Basic ${auth}`,
                'Accept': 'application/json',
              },
            }
          );

          const data = await response.json();
          results.sources_checked.push({
            source: 'DeHashed',
            found: data.total > 0,
            results_count: data.total,
            entries: data.entries?.slice(0, 10),
          });
        } catch (error) {
          results.sources_checked.push({
            source: 'DeHashed',
            error: error.message,
          });
        }
      }

      // Intelligence X (requires API key)
      if (process.env.INTELX_API_KEY) {
        results.sources_checked.push({
          source: 'IntelligenceX',
          note: 'API integration available with key',
          url: 'https://intelx.io',
        });
      }

      return JSON.stringify(results, null, 2);
    }

    case 'alfa_osint_domain_reconnaissance': {
      const results = {
        domain: args.domain,
        timestamp: new Date().toISOString(),
        reconnaissance: {},
      };

      // DNS records
      try {
        const dnsA = execSync(`dig +short A ${args.domain}`, { encoding: 'utf8' });
        const dnsMX = execSync(`dig +short MX ${args.domain}`, { encoding: 'utf8' });
        const dnsTXT = execSync(`dig +short TXT ${args.domain}`, { encoding: 'utf8' });

        results.reconnaissance.dns = {
          A: dnsA.trim().split('\n'),
          MX: dnsMX.trim().split('\n'),
          TXT: dnsTXT.trim().split('\n'),
        };
      } catch (error) {
        results.reconnaissance.dns = { error: error.message };
      }

      // Subdomains (via crt.sh)
      if (args.scan_subdomains) {
        try {
          const response = await fetch(`https://crt.sh/?q=%.${args.domain}&output=json`);
          const data = await response.json();
          const subdomains = [...new Set(data.map(cert => cert.name_value))];

          results.reconnaissance.subdomains = {
            count: subdomains.length,
            list: subdomains.slice(0, 50),
          };
        } catch (error) {
          results.reconnaissance.subdomains = { error: error.message };
        }
      }

      // WHOIS
      try {
        const whois = execSync(`whois ${args.domain}`, { encoding: 'utf8' });
        results.reconnaissance.whois = whois.split('\n').slice(0, 30).join('\n');
      } catch (error) {
        results.reconnaissance.whois = { error: error.message };
      }

      // Technologies detection (via BuiltWith API or Wappalyzer)
      if (args.detect_technologies) {
        results.reconnaissance.technologies = {
          note: 'Use BuiltWith API or Wappalyzer for detailed tech stack',
          url: `https://builtwith.com/${args.domain}`,
        };
      }

      return JSON.stringify(results, null, 2);
    }

    case 'alfa_osint_executive_team_mapping': {
      const results = {
        company: args.company_name,
        timestamp: new Date().toISOString(),
        executives: [],
        sources: [],
      };

      // LinkedIn company page scraping (via Google)
      results.sources.push({
        source: 'LinkedIn',
        search_url: `https://www.google.com/search?q=site:linkedin.com/in "${args.company_name}" (CEO OR CFO OR CTO OR Director OR "Vice President")`,
        method: 'Google Dork for executives',
      });

      // Pappers dirigeants
      if (process.env.PAPPERS_API_KEY) {
        try {
          const response = await fetch(
            `https://api.pappers.fr/v2/entreprise?api_token=${process.env.PAPPERS_API_KEY}&nom_entreprise=${encodeURIComponent(args.company_name)}`
          );
          const data = await response.json();

          results.executives = data.representants?.map(rep => ({
            name: `${rep.prenom} ${rep.nom}`,
            role: rep.qualite,
            birthdate: rep.date_naissance,
            address: rep.adresse_ligne_1,
          })) || [];

          results.sources.push({
            source: 'Pappers',
            executives_count: results.executives.length,
          });
        } catch (error) {
          results.sources.push({ source: 'Pappers', error: error.message });
        }
      }

      // Societe.com dirigeants
      results.sources.push({
        source: 'Societe.com',
        url: `https://www.societe.com/cgi-bin/search?champs=${encodeURIComponent(args.company_name)}`,
        note: 'Check for executive team details',
      });

      return JSON.stringify(results, null, 2);
    }

    default:
      throw new Error(`Unknown OSINT tool: ${name}`);
  }
}
