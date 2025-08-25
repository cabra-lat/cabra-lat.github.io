const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const previewsDir = '_site/previews/';
const outputDir = 'previews/';
fs.mkdirSync(outputDir, { recursive: true });

(async () => {
    const browser = await puppeteer.launch({
        args: ['--no-sandbox', '--disable-setuid-sandbox'], // Add this line
    });

    const page = await browser.newPage();
  
    // Set the viewport size to 1200x630
    await page.setViewport({
        width: 1200,
        height: 630,
    }); 

    const files = fs.readdirSync(previewsDir).filter(file => file.endsWith('.html'));

    for (const file of files) {
        const filePath = `file://${path.resolve(previewsDir, file)}`;
        const outputFilePath = path.resolve(outputDir, `${path.basename(file, '.html')}.png`);

        console.log(`Rendering ${filePath} to ${outputFilePath}`);

        await page.goto(filePath, { waitUntil: 'load' });
        await page.screenshot({ path: outputFilePath, fullPage: true });
    }

    await browser.close();
})();
