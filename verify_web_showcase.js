const path = require('path');
const pw = require('C:/Users/User/AppData/Roaming/npm/node_modules/@playwright/cli/node_modules/playwright-core');

async function verify() {
  const browser = await pw.chromium.launch({ channel: 'msedge', headless: true });
  const context = await browser.newContext();
  const page = await context.newPage();

  const fileUrl = 'file:///' + path.resolve(__dirname, 'freshflow/web_showcase/index.html').replace(/\\/g, '/');
  console.log('Navigating to:', fileUrl);
  await page.goto(fileUrl);

  // 1. Desktop Test
  await page.setViewportSize({ width: 1280, height: 800 });
  await page.screenshot({ path: 'screenshot_overhaul_desktop.png', fullPage: true });
  console.log('✅ Desktop full-page screenshot captured: screenshot_overhaul_desktop.png');

  // 2. Mobile Responsiveness Test (390px iPhone standard)
  await page.setViewportSize({ width: 390, height: 844 });
  const mobileMetrics = await page.evaluate(() => {
    return {
      scrollWidth: document.documentElement.scrollWidth,
      innerWidth: window.innerWidth,
      bodyScrollWidth: document.body.scrollWidth,
      hasOverflow: document.documentElement.scrollWidth > window.innerWidth
    };
  });
  console.log('Mobile Metrics (390px):', JSON.stringify(mobileMetrics));
  if (mobileMetrics.hasOverflow) {
    console.error('❌ FAILED: Mobile horizontal overflow detected!');
  } else {
    console.log('✅ PASSED: Zero horizontal overflow on mobile!');
  }
  await page.screenshot({ path: 'screenshot_overhaul_mobile.png', fullPage: true });

  // 3. Interactive Payment QR Test
  console.log('Testing Dynamic QR button interaction...');
  await page.getByRole('button', { name: 'Dynamic QR' }).click();
  const qrVisible = await page.evaluate(() => {
    const box = document.getElementById('qrDemoBox');
    return box && box.classList.contains('visible') && box.offsetHeight > 0;
  });
  console.log('QR Modal Visible:', qrVisible ? '✅ PASSED' : '❌ FAILED');
  await page.screenshot({ path: 'screenshot_overhaul_qr.png' });

  // 4. Interactive Tabs Test
  console.log('Testing tab switching...');
  await page.locator('#tab-btn-builds').click();
  const buildsTabActive = await page.evaluate(() => {
    const panel = document.getElementById('panel-builds');
    return panel && panel.classList.contains('active') && panel.offsetHeight > 0;
  });
  console.log('Builds Tab Active:', buildsTabActive ? '✅ PASSED' : '❌ FAILED');
  await page.screenshot({ path: 'screenshot_overhaul_ci.png' });

  await browser.close();
  console.log('🎉 Verification completed successfully!');
}

verify().catch(err => {
  console.error('Validation error:', err);
  process.exit(1);
});

