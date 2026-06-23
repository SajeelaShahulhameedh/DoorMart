<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%
    Integer userId = (Integer) session.getAttribute("userId");
    String userName = (String) session.getAttribute("userName");
    if (userId == null) {
        response.sendRedirect("http://localhost:8080/DoorMart/login.html");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Shops - DoorMart</title>
  <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@tabler/icons-webfont@latest/tabler-icons.min.css">
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; background: #f5f5f5; }
    nav { background: #C0392B; padding: 14px 24px; display: flex; justify-content: space-between; align-items: center; }
    nav h2 { color: white; font-size: 18px; font-weight: 500; display: flex; align-items: center; gap: 8px; }
    nav a { color: rgba(255,255,255,0.85); text-decoration: none; font-size: 14px; }
    .hero { background: #C0392B; padding: 20px 24px 32px; color: white; }
    .hero h1 { font-size: 20px; font-weight: 500; margin-bottom: 4px; }
    .hero p { font-size: 14px; opacity: 0.85; margin-bottom: 16px; }
    .search-box { display: flex; background: white; border-radius: 10px; overflow: hidden; }
    .search-box input { flex: 1; padding: 10px 14px; border: none; outline: none; font-size: 14px; color: #333; }
    .search-box button { background: #A93226; color: white; border: none; padding: 10px 16px; cursor: pointer; }
    .container { padding: 20px; margin-top: -12px; }
    .section-title { font-size: 15px; font-weight: 500; color: #2c3e50; margin-bottom: 14px; }
    .shop-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(200px, 1fr)); gap: 12px; }
    .shop-card { background: white; border: 0.5px solid #e0e0e0; border-radius: 14px; padding: 16px; cursor: pointer; transition: border-color 0.2s; }
    .shop-card:hover { border-color: #C0392B; }
    .shop-header { display: flex; align-items: center; gap: 10px; margin-bottom: 12px; }
    .shop-icon { width: 42px; height: 42px; background: #FCEBEB; border-radius: 10px; display: flex; align-items: center; justify-content: center; flex-shrink: 0; }
    .shop-icon i { color: #C0392B; font-size: 20px; }
    .shop-name { font-size: 14px; font-weight: 500; color: #2c3e50; }
    .shop-desc { font-size: 12px; color: #888; margin-top: 2px; }
    .shop-footer { display: flex; justify-content: space-between; align-items: center; padding-top: 10px; border-top: 0.5px solid #f0f0f0; }
    .shop-address { font-size: 12px; color: #888; display: flex; align-items: center; gap: 4px; }
    .open-badge { background: #EAF3DE; color: #3B6D11; font-size: 11px; padding: 3px 10px; border-radius: 20px; font-weight: 500; }
    .empty { text-align: center; color: #888; padding: 3rem; }
    .empty i { font-size: 48px; color: #ddd; display: block; margin-bottom: 12px; }
  </style>
</head>
<body>

  <nav>
    <h2><i class="ti ti-home" aria-hidden="true"></i> DoorMart</h2>
    <a href="http://localhost:8080/DoorMart/login.html">Logout</a>
  </nav>

  <div class="hero">
    <h1>Welcome, <%= userName %>!</h1>
    <p>Browse nearby shops and order from home</p>
    <div class="search-box">
      <input type="text" id="searchInput" placeholder="Search shops..." oninput="filterShops()" />
      <button><i class="ti ti-search" aria-hidden="true"></i></button>
    </div>
  </div>

  <div class="container">
    <p class="section-title">Nearby Shops</p>
    <div class="shop-grid" id="shops-area">
      <p class="empty"><i class="ti ti-building-store" aria-hidden="true"></i>Loading shops...</p>
    </div>
  </div>

  <script>
    let allShops = [];
    window.onload = loadShops;

    function loadShops() {
      fetch('http://localhost:8080/DoorMart/ShopServlet?action=all')
        .then(response => response.json())
        .then(shops => {
          allShops = shops;
          renderShops(shops);
        });
    }

    function filterShops() {
      const search = document.getElementById('searchInput').value.toLowerCase();
      const filtered = allShops.filter(s =>
        s.shopName.toLowerCase().includes(search) ||
        s.address.toLowerCase().includes(search)
      );
      renderShops(filtered);
    }

    function renderShops(shops) {
      const area = document.getElementById('shops-area');
      if (shops.length === 0) {
        area.innerHTML = '<p class="empty"><i class="ti ti-building-store"></i>No shops available yet.</p>';
        return;
      }
      let html = '';
      for (let i = 0; i < shops.length; i++) {
        let s = shops[i];
        html += '<div class="shop-card" onclick="window.location=\'http://localhost:8080/DoorMart/customer/products.jsp?shopId=' + s.id + '\'">';
        html += '<div class="shop-header">';
        html += '<div class="shop-icon"><i class="ti ti-building-store" aria-hidden="true"></i></div>';
        html += '<div><p class="shop-name">' + s.shopName + '</p><p class="shop-desc">' + s.description + '</p></div>';
        html += '</div>';
        html += '<div class="shop-footer">';
        html += '<span class="shop-address"><i class="ti ti-map-pin" aria-hidden="true"></i>' + s.address + '</span>';
        html += '<span class="open-badge">Open</span>';
        html += '</div>';
        html += '</div>';
      }
      area.innerHTML = html;
    }
  </script>

</body>
</html>