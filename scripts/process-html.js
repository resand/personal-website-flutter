#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const { minify } = require('html-minifier-terser');

/**
 * HTML Processing Script for Flutter Web SEO
 * Replaces template placeholders with actual values from configuration
 */

// Configuration paths
const WEBSITE_CONFIG_PATH = 'assets/config/website_config_default.json';
const SEO_CONFIG_PATH = 'assets/config/seo_config.json';

const HTML_PATH = 'build/web/index.html';
// For dynamic language switching on same URL, we only generate one HTML file
// with default language (Spanish) meta tags. User language preference is handled by Flutter.
const OUTPUT_PATH = 'build/web/index.html';

function loadConfig(configPath) {
  try {
    const configContent = fs.readFileSync(configPath, 'utf8');
    return JSON.parse(configContent);
  } catch (error) {
    console.error(`Error loading config from ${configPath}:`, error.message);
    process.exit(1);
  }
}

function loadTemplate() {
  try {
    return fs.readFileSync(HTML_PATH, 'utf8');
  } catch (error) {
    console.error(`Error loading HTML template from ${HTML_PATH}:`, error.message);
    process.exit(1);
  }
}

function processHtml(template, websiteConfig, seoConfig) {
  const personalInfo = websiteConfig.personal_info;
  const socialLinks = websiteConfig.social_links || [];
  
  // Extract social media handles from we config
  const twitterLink = socialLinks.find(link => link.platform === 'x' || link.platform === 'twitter');
  const twitterHandle = twitterLink ? twitterLink.url.split('/').pop() : '';
  
  // Use SEO config for all meta information
  // For dynamic language switching, all URLs point to the same base URL
  const siteUrl = seoConfig.site_info.base_url;
  const baseUrl = seoConfig.site_info.base_url;
  
  // Replace all placeholders
  const replacements = {
    '{{LANG_CODE}}': seoConfig.meta_tags.language,
    '{{META_TITLE}}': seoConfig.meta_tags.title,
    '{{META_DESCRIPTION}}': seoConfig.meta_tags.description,
    '{{META_KEYWORDS}}': seoConfig.meta_tags.keywords.join(', '),
    '{{AUTHOR_NAME}}': seoConfig.meta_tags.author,
    '{{SITE_URL}}': siteUrl,
    '{{BASE_URL}}': baseUrl,
    '{{AVATAR_URL}}': personalInfo.avatar_url,
    '{{SITE_NAME}}': seoConfig.site_info.site_name,
    '{{LOCALE}}': seoConfig.meta_tags.locale,
    '{{TWITTER_HANDLE}}': seoConfig.twitter.creator,
    '{{JOB_TITLE}}': seoConfig.structured_data.job_title,
    '{{STRUCTURED_DESCRIPTION}}': seoConfig.structured_data.description,
    '{{SOCIAL_LINKS_JSON}}': JSON.stringify(seoConfig.structured_data.same_as),
    '{{ORGANIZATION}}': seoConfig.structured_data.organization,
    '{{ORGANIZATION_URL}}': seoConfig.structured_data.organization_url,
    '{{SKILLS_JSON}}': JSON.stringify(seoConfig.structured_data.skills),
    '{{EDUCATION}}': seoConfig.structured_data.education,
    '{{CITY}}': seoConfig.structured_data.address.locality,
    '{{COUNTRY}}': seoConfig.structured_data.address.country,
    '{{ANALYTICS_ID}}': seoConfig.analytics.google_analytics_id
  };
  
  let processedHtml = template;
  
  // Replace all placeholders
  Object.entries(replacements).forEach(([placeholder, value]) => {
    const regex = new RegExp(placeholder.replace(/[.*+?^${}()|[\]\\]/g, '\\$&'), 'g');
    processedHtml = processedHtml.replace(regex, value || '');
  });
  
  return processedHtml;
}

async function minifyHtml(html) {
  try {
    const minified = await minify(html, {
      collapseWhitespace: true,
      removeComments: true,
      removeRedundantAttributes: true,
      removeScriptTypeAttributes: true,
      removeStyleLinkTypeAttributes: true,
      useShortDoctype: true,
      minifyCSS: true,
      minifyJS: true,
      removeEmptyAttributes: true,
      removeOptionalTags: false, // Keep for better compatibility
      html5: true
    });
    return minified;
  } catch (error) {
    console.warn('⚠️  HTML minification failed, using original HTML:', error.message);
    return html;
  }
}

function ensureDirectoryExists(filePath) {
  const directory = path.dirname(filePath);
  if (!fs.existsSync(directory)) {
    fs.mkdirSync(directory, { recursive: true });
  }
}

async function main() {
  console.log('🔧 Processing HTML templates for SEO...');
  
  try {
    // Load the HTML template
    const template = loadTemplate();
    
    console.log('📝 Processing default language version...');
    
    // Load configurations  
    const websiteConfig = loadConfig(WEBSITE_CONFIG_PATH);
    const seoConfig = loadConfig(SEO_CONFIG_PATH);
    
    // Process HTML
    const processedHtml = processHtml(template, websiteConfig, seoConfig);
    
    // Minify HTML for performance
    console.log('🗜️  Minifying HTML for performance...');
    const minifiedHtml = await minifyHtml(processedHtml);
    
    // Calculate compression stats
    const originalSize = Buffer.byteLength(processedHtml, 'utf8');
    const minifiedSize = Buffer.byteLength(minifiedHtml, 'utf8');
    const compressionRatio = ((originalSize - minifiedSize) / originalSize * 100).toFixed(1);
    
    // Ensure directory exists
    ensureDirectoryExists(OUTPUT_PATH);
    
    // Write processed HTML
    fs.writeFileSync(OUTPUT_PATH, minifiedHtml, 'utf8');
    
    console.log(`✅ HTML processed and minified: ${OUTPUT_PATH}`);
    console.log(`📊 Compression: ${originalSize} bytes → ${minifiedSize} bytes (${compressionRatio}% reduction)`);
    console.log('🎉 HTML processing completed successfully!');
    
  } catch (error) {
    console.error('❌ Error processing HTML:', error.message);
    process.exit(1);
  }
}

// Run the script
if (require.main === module) {
  main();
}

module.exports = { processHtml, loadConfig };