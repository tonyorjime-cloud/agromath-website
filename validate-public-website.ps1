$ErrorActionPreference = "Stop"

function Assert-True {
  param([bool]$Condition, [string]$Message)
  if (-not $Condition) { throw $Message }
}

$pages = @("index.html", "faq.html", "privacy.html", "terms.html")
foreach ($page in $pages) {
  $html = Get-Content -LiteralPath (Join-Path $PSScriptRoot $page) -Raw
  Assert-True (([regex]::Matches($html, '<h1\b')).Count -eq 1) "$page must have exactly one h1"
  foreach ($match in [regex]::Matches($html, '<a\b(?=[^>]*target="_blank")[^>]*>')) {
    Assert-True ($match.Value -match 'rel="noopener noreferrer"') "$page has an unsafe new-tab link"
  }
  foreach ($match in [regex]::Matches($html, '(?:src|href)="(assets/[^"]+)"')) {
    Assert-True (Test-Path -LiteralPath (Join-Path $PSScriptRoot $match.Groups[1].Value)) "$page references a missing local asset"
  }
}

$index = Get-Content -LiteralPath (Join-Path $PSScriptRoot "index.html") -Raw
$css = Get-Content -LiteralPath (Join-Path $PSScriptRoot "styles.css") -Raw
$required = @(
  '<title>AgroMath | Buy and sell foodstuff in Nigeria</title>',
  'How AgroMath connects you',
  'Buyer Requests so eligible sellers can respond.',
  'within your order to clarify details',
  'unread-message indicators',
  'Optional push alerts depend on your permission, connection and device.',
  'For applicable seller-delivery orders',
  'Any proposed extension requires your agreement.',
  'Pickup and delivery options depend on the seller, location and order.',
  'Choose Sell when you register',
  'href="https://app.agromath.com.ng/products/"',
  'href="https://app.agromath.com.ng/auth/register"',
  'href="https://app.agromath.com.ng/auth/login"',
  'href="https://app.agromath.com.ng/help/"',
  'href="https://agromath.com.ng/privacy.html"',
  'href="https://agromath.com.ng/terms.html"',
  'rel="canonical" href="https://agromath.com.ng/"',
  'assets/images/refresh/homepage.webp',
  'assets/images/refresh/sellers.webp',
  'assets/images/refresh/buyers.webp'
)
foreach ($text in $required) {
  Assert-True ($index.Contains($text)) "Missing homepage content: $text"
}
$removed = @(
  'Controlled Abuja pilot',
  'Order foodstuff from sellers in Abuja.',
  'More people. More ways to connect.',
  'agromath-pilot.onrender.com',
  'pending confirmation',
  'noindex',
  'guaranteed delivery',
  'instant payout',
  'escrow protection'
)
foreach ($text in $removed) {
  Assert-True (-not $index.Contains($text)) "Homepage still contains excluded wording: $text"
}
foreach ($match in [regex]::Matches($index, 'href="#([^"]+)"')) {
  $id = $match.Groups[1].Value
  Assert-True ($index.Contains('id="' + $id + '"')) "Broken homepage navigation anchor: $id"
}
Assert-True ($css.Contains('.connections')) "Connection section styling is missing"
Assert-True ($css.Contains('.mobile-nav')) "Phone navigation styling is missing"
Assert-True ($css.Contains('min-height:48px')) "Touch target minimum is missing"
Assert-True (([regex]::Matches($index, 'class="brand-mark"')).Count -eq 2) "Expected approved brand marks in header and footer"
"Public website validation passed."
