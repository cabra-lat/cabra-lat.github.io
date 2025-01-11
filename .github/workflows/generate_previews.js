const puppeteer = require('puppeteer');
const fs = require('fs');
const path = require('path');

const previewsDir = '_site/';
const outputDir = '_site/previews/';
fs.mkdirSync(outputDir, { recursive: true });

(async () => {
    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    const files = fs.readdirSync(previewsDir).filter(file => file.endsWith('.png.html'));

    for (const file of files) {
        const filePath = `file://${path.resolve(previewsDir, file)}`;
        const outputFilePath = path.resolve(outputDir, `${path.basename(file, '.png.html')}.png`);

        console.log(`Rendering ${filePath} to ${outputFilePath}`);

        await page.goto(filePath, { waitUntil: 'networkidle0' });
        await page.screenshot({ path: outputFilePath, fullPage: true });
    }

    await browser.close();
})();
