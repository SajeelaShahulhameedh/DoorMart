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
  <title>Owner Dashboard - DoorMart</title>
  <style>
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body { font-family: Arial, sans-serif; background: #f5f5f5; }
    nav { background: #e74c3c; padding: 1rem 2rem; display: flex; justify-content: space-between; align-items: center; }
    nav h2 { color: white; font-size: 20px; }
    nav div { display: flex; gap: 20px; }
    nav a { color: white; text-decoration: none; font-size: 14px; }
    .container { max-width: 900px; margin: 2rem auto; padding: 0 1rem; }
    h1 { font-size: 24px; color: #2c3e50; margin-bottom: 0.5rem; }
    p { color: #666; margin-bottom: 1.5rem; }
    .section { background: white; border-radius: 12px; padding: 1.5rem; margin-bottom: 1.5rem; box-shadow: 0 2px 8px rgba(0,0,0,0.08); }
    .section h2 { font-size: 18px; color: #2c3e50; margin-bottom: 1rem; }
    input, textarea { width: 100%; padding: 10px; border: 1px solid #ddd; border-radius: 8px; font-size: 14px; margin-bottom: 1rem; }
    button { padding: 10px 24px; background: #e74c3c; color: white; border: none; border-radius: 8px; font-size: 14px; cursor: pointer; }
    button:hover { background: #c0392b; }
    .btn-small { padding: 6px 14px; font-size: 12px; }
    table { width: 100%; border-collapse: collapse; font-size: 14px; }
    th { padding: 10px; background: #f5f5f5; text-align: left; border-bottom: 1px solid #ddd; color: #2c3e50; }
    td { padding: 10px; border-bottom: 1px solid #eee; color: #444; }
    .badge { padding: 4px 10px; border-radius: 20px; font-size: 12px; }
    .badge-green { background: #e8f8e8; color: #27ae60; }
    .badge-red { background: #fde8e8; color: #e74c3c; }
  </style>
</head>
<body>

  <nav>
    <h2>🚪 DoorMart</h2>
    <div>
      <a href="/DoorMart/owner/setup.jsp">Setup Shop</a>
      <a href="/DoorMart/login.html">Logout</a>
    </div>
  </nav>

  <div class="container">
    <h1>Welcome, <%= userName %>! 👋</h1>
    <p>Manage your shop, products and orders!</p>

    <!-- Add Product -->
    <div class="section">
      <h2>Add New Product</h2>
      <form action="http://localhost:8080/DoorMart/ProductServlet" method="POST">
        <input type="text" name="name" placeholder="Product Name" required />
        <textarea name="description" placeholder="Product Description" rows="2"></textarea>
        <input type="number" name="price" placeholder="Price (Rs.)" required />
        <button type="submit">Add Product</button>
      </form>
    </div>

    <!-- Products List -->
    <div class="section">
      <h2>My Products</h2>
      <div id="products-area">Loading...</div>
    </div>

  </div>

  <script>
    window.onload = loadProducts;

    function loadProducts() {
      fetch('http://localhost:8080/DoorMart/ProductServlet')
        .then(response => response.json())
        .then(products => {
          const area = document.getElementById('products-area');
          if (products.length === 0) {
            area.innerHTML = 'No products added yet.';
            return;
          }
          let rows = '';
          for (let i = 0; i < products.length; i++) {
            let p = products[i];
            let status = p.isAvailable == 1 ? 'Available' : 'Sold Out';
            let badgeClass = p.isAvailable == 1 ? 'badge-green' : 'badge-red';
            let btnText = p.isAvailable == 1 ? 'Mark Sold' : 'Mark Available';
            rows += '<tr>';
            rows += '<td>' + p.name + '</td>';
            rows += '<td>' + p.description + '</td>';
            rows += '<td>Rs. ' + p.price + '</td>';
            rows += '<td><span class="badge ' + badgeClass + '">' + status + '</span></td>';
            rows += '<td><form action="http://localhost:8080/DoorMart/ProductServlet" method="POST" style="display:inline">';
            rows += '<input type="hidden" name="action" value="toggle" />';
            rows += '<input type="hidden" name="productId" value="' + p.id + '" />';
            rows += '<button class="btn-small" type="submit">' + btnText + '</button>';
            rows += '</form></td>';
            rows += '</tr>';
          }
          area.innerHTML = '<table><thead><tr><th>Name</th><th>Description</th><th>Price</th><th>Status</th><th></th></tr></thead><tbody>' + rows + '</tbody></table>';
        });
    }
  </script>

</body>
</html>