$ErrorActionPreference = "Stop"

$pages = @("index.html", "faq.html", "privacy.html", "terms.html")
$preferredWhatsAppUrl = "https://wa.me/2348112812709?text=Hello%20AgroMath"
$staleAppUrl = "https://agromath-mvp-lgez.onrender.com/login"
$pilotBaseUrl = "https://agromath-pilot.onrender.com"
$brandLogo = "assets/brand/agromath-mark-96.png"
$socialImage = "https://agromath.com.ng/assets/brand/agromath-logo-full.png"
$requiredBrandAssets = @(
  "assets/brand/agromath-mark.png",
  "assets/brand/agromath-mark-96.png",
  "assets/brand/agromath-logo.png",
  "assets/brand/agromath-logo-full.png",
  "assets/brand/apple-touch-icon-180.png",
  "assets/brand/favicon-32.png",
  "assets/brand/favicon-16.png",
  "assets/brand/favicon.ico"
)
$homepageBannedCopy = @(
  "Buy. Sell. Deliver.",
  "across Nigeria",
  "approved sellers",
  "fulfilment",
  "settlement",
  "locked total",
  "order portion",
  "farmer account",
  "Offer Transport Services",
  "transport quotes",
  "route estimates",
  "Approved Sellers &bull; Buyers &bull; Transporters"
)

function Assert-True {
  param(
    [bool]$Condition,
    [string]$Message
  )
  if (-not $Condition) {
    throw $Message
  }
}

foreach ($asset in $requiredBrandAssets) {
  Assert-True (Test-Path -LiteralPath $asset) "Missing approved brand asset: $asset"
}

foreach ($page in $pages) {
  $html = Get-Content -LiteralPath $page -Raw

  Assert-True ($html -notmatch [regex]::Escape($staleAppUrl)) "$page still references the stale MVP app URL"
  Assert-True ($html -match 'class="whatsapp-support"') "$page is missing the floating WhatsApp support link"
  Assert-True (([regex]::Matches($html, 'class="whatsapp-support"')).Count -eq 1) "$page has duplicate floating WhatsApp support links"
  Assert-True ($html -match [regex]::Escape('href="' + $preferredWhatsAppUrl + '"')) "$page floating/support WhatsApp URL is not using the preferred prefilled message"
  Assert-True ($html -match 'aria-label="Chat with AgroMath support on WhatsApp"') "$page floating WhatsApp link is missing the accessible label"
  Assert-True ($html -match 'aria-hidden="true"') "$page decorative WhatsApp SVG is missing aria-hidden"
  Assert-True ($html -match 'target="_blank"') "$page should open external support/app links in a new tab"

  Assert-True ($html -notmatch 'class="mark"') "$page still uses the old official .mark branding"
  Assert-True ($html -notmatch [regex]::Escape('M5 18c7.5 0 12-4.5 14-13-7.5 0-12 4.5-14 13Z')) "$page still contains the old simple-leaf SVG path"
  Assert-True ($html -notmatch 'href="favicon\.svg"') "$page still references favicon.svg"
  Assert-True ($html -match [regex]::Escape('src="' + $brandLogo + '"')) "$page header does not reference the approved brand mark"
  Assert-True ($html -match 'class="brand-mark"') "$page is missing the brand-mark class"
  Assert-True ($html -match 'rel="icon" href="assets/brand/favicon.ico" sizes="any"') "$page is missing the approved ico favicon reference"
  Assert-True ($html -match 'rel="icon" type="image/png" sizes="32x32" href="assets/brand/favicon-32.png"') "$page is missing the approved 32px favicon reference"
  Assert-True ($html -match 'rel="icon" type="image/png" sizes="16x16" href="assets/brand/favicon-16.png"') "$page is missing the approved 16px favicon reference"
  Assert-True ($html -match 'rel="apple-touch-icon" sizes="180x180" href="assets/brand/apple-touch-icon-180.png"') "$page is missing the approved Apple touch icon reference"
}

$index = Get-Content -LiteralPath "index.html" -Raw
Assert-True ($index -notmatch '>WhatsApp Help<') "index.html still has the duplicate header WhatsApp Help button"
Assert-True ($index -notmatch 'href="#"') "index.html still contains a dead href=# link"
Assert-True ($index -match [regex]::Escape('href="' + $pilotBaseUrl + '/"')) "index.html is missing the Pilot app base URL for app entry CTAs"
Assert-True ($index -match [regex]::Escape('content="' + $socialImage + '"')) "index.html is missing the approved absolute social image URL"
Assert-True (([regex]::Matches($index, [regex]::Escape('src="' + $brandLogo + '"'))).Count -ge 2) "index.html should use the approved brand mark in header and footer"
Assert-True ($index -match '<title>AgroMath \| Buy and sell foodstuff in Abuja</title>') "index.html has the wrong homepage title"
Assert-True ($index -match 'Order foodstuff from sellers in Abuja\.') "index.html is missing the approved hero headline"
Assert-True ($index -match 'Pay on AgroMath\. Collect it, or they bring it\.') "index.html is missing the approved hero subline"
Assert-True ($index -match '>Buy foodstuff<') "index.html is missing the Buy foodstuff CTA"
Assert-True ($index -match '>Sell foodstuff<') "index.html is missing the Sell foodstuff CTA"
Assert-True ($index -match 'Abuja, Nigeria') "index.html is missing the Abuja footer/location line"
foreach ($copy in $homepageBannedCopy) {
  Assert-True ($index -notmatch [regex]::Escape($copy)) "index.html still contains banned homepage copy: $copy"
}

$faq = Get-Content -LiteralPath "faq.html" -Raw
Assert-True ($faq -notmatch 'Call or WhatsApp <a href="tel:08112812709"') "faq.html still has a misleading combined Call/WhatsApp tel link"
Assert-True ($faq -match [regex]::Escape('href="' + $pilotBaseUrl + '/"')) "faq.html is missing the Pilot app base URL for app entry CTAs"
Assert-True ($faq -notmatch 'Screenshot needed') "faq.html still contains visible screenshot placeholder labels"
Assert-True ($faq -notmatch 'Screenshot needed showing') "faq.html still contains screenshot-needed aria labels"
Assert-True ($faq -notmatch 'image-number') "faq.html still contains image-number placeholders"
Assert-True ($faq -notmatch 'shot-box') "faq.html still renders placeholder screenshot boxes"
Assert-True ($faq -match 'What does AgroMath do\?') "faq.html is missing the what AgroMath does answer"
Assert-True ($faq -match 'Who can sell\?') "faq.html is missing the seller answer"
Assert-True ($faq -match 'How do I buy\?') "faq.html is missing the buyer answer"
Assert-True ($faq -match 'How does pickup or seller delivery work\?') "faq.html is missing the pickup/seller delivery answer"
Assert-True ($faq -match 'How does payment work\?') "faq.html is missing the payment answer"
Assert-True ($faq -match 'How do I get help\?') "faq.html is missing the help answer"
Assert-True ($faq -match 'Certificate upload is not required to start\.') "faq.html is missing the certificate note"
Assert-True ($faq -notmatch 'Transport with AgroMath') "faq.html still documents transporter setup"

$privacy = Get-Content -LiteralPath "privacy.html" -Raw
$terms = Get-Content -LiteralPath "terms.html" -Raw
Assert-True (([regex]::Matches($privacy, '<h1\b')).Count -eq 1) "privacy.html should contain exactly one h1"
Assert-True (([regex]::Matches($terms, '<h1\b')).Count -eq 1) "terms.html should contain exactly one h1"
Assert-True ($privacy -notmatch 'Termii') "privacy.html still contains provider-specific Termii wording"

foreach ($page in $pages) {
  $html = Get-Content -LiteralPath $page -Raw
  $blankLinks = [regex]::Matches($html, '<a\b(?=[^>]*target="_blank")[^>]*>')
  foreach ($match in $blankLinks) {
    Assert-True ($match.Value -match 'rel="noopener noreferrer"') "$page has target=_blank link without rel=noopener noreferrer: $($match.Value)"
  }
}

"Public website validation passed."
