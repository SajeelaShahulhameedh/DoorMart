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
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; background: #f5f5f5; }
    nav { background: #e74c3c; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
    nav h2 { color: white; font-size: 20px; }
    nav a { color: white; text-decoration: none; font-size: 14px; }
    .container { max-width: 900px; margin: 2rem auto; padding: 0 1rem; }
    h1 { font-size: 24px; color: #2c3e50; margin-bottom: 0.5rem; }
    p { color: #666; margin-bottom: 1.5rem; }
    .shop-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 1rem; }
    .shop-card { background: white; border-radius: 12px; padding: 1.5rem; box-shadow: 0 2px 8px rgba(0,0,0,0.08); cursor: pointer; }
    .shop-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.15); }
    .shop-card h3 { font-size: 18px; color: #2c3e50; margin-bottom: 0.5rem; }
    .shop-card p { font-size: 14px; color: #666; margin-bottom: 0.5rem; }
    .shop-card .phone { font-size: 13px; color: #e74c3c; }
    .shop-card .address { font-size: 13px; color: #999; }
    .badge-open { display: inline-block; padding: 4px 10px; background: #e8f8e8; color: #27ae60; border-radius: 20px; font-size: 12px; margin-bottom: 0.5rem; }
    .empty { text-align: center; color: #666; padding: 3rem; }
  </style>
</head>
<body>

  <nav>
    <h2>🚪 DoorMart</h2>
    <a href="/DoorMart/login.html">Logout</a>
  </nav>

  <div class="container">
    <h1>Welcome, <%= userName %>! 😊</h1>
    <p>Browse nearby shops and order from home!</p>

    <div class="shop-grid" id="shops-area">
      <p class="empty">Loading shops...</p>
    </div>
  </div>

  <script>
    window.onload = loadShops;

    function loadShops() {
  fetch('/DoorMart/ShopServlet?action=all')
    .then(response => response.json())
    .then(shops => {
      const area = document.getElementById('shops-area');
      if (shops.length === 0) {
        area.innerHTML = '<p class="empty">No shops available yet.</p>';
        return;
      }
      let html = '';
      for (let i = 0; i < shops.length; i++) {
        let s = shops[i];
        html += '<div class="shop-card" onclick="window.location=\'http://localhost:8080/DoorMart/customer/products.jsp?shopId=' + s.id + '\'">';
        html += '<span class="badge-open">🟢 Open</span>';
        html += '<h3>🏪 ' + s.shopName + '</h3>';
        html += '<p>' + s.description + '</p>';
        html += '<p class="phone">📞 ' + s.phone + '</p>';
        html += '<p class="address">📍 ' + s.address + '</p>';
        html += '</div>';
      }
      area.innerHTML = html;
    });
}
  </script>

</body>
</html>
