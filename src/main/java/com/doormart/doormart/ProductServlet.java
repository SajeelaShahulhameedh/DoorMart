package com.doormart.doormart;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet("/ProductServlet")
public class ProductServlet extends HttpServlet {

    // GET - get all products for a shop
    
    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession();
    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect("http://localhost:8080/DoorMart/login.html");
        return;
    }

    response.setContentType("application/json");
    PrintWriter out = response.getWriter();

    try {
        Connection conn = DBConnection.getConnection();
        String shopIdParam = request.getParameter("shopId");

        if (shopIdParam != null) {
            // Customer requesting products for a specific shop
            int shopId = Integer.parseInt(shopIdParam);

            // Get shop name
            String shopSql = "SELECT shop_name FROM shops WHERE id = ?";
            PreparedStatement shopPs = conn.prepareStatement(shopSql);
            shopPs.setInt(1, shopId);
            ResultSet shopRs = shopPs.executeQuery();
            String shopName = "";
            if (shopRs.next()) {
                shopName = shopRs.getString("shop_name");
            }

            // Get products
            String sql = "SELECT * FROM products WHERE shop_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, shopId);
            ResultSet rs = ps.executeQuery();

            StringBuilder json = new StringBuilder("{\"shopName\":\"" + shopName + "\",\"products\":[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{")
                    .append("\"id\":").append(rs.getInt("id")).append(",")
                    .append("\"name\":\"").append(rs.getString("name")).append("\",")
                    .append("\"description\":\"").append(rs.getString("description")).append("\",")
                    .append("\"price\":").append(rs.getDouble("price")).append(",")
                    .append("\"isAvailable\":").append(rs.getInt("is_available"))
                    .append("}");
                first = false;
            }
            json.append("]}");
            out.print(json.toString());

        } else {
            // Owner requesting their own products
            String sql = "SELECT p.* FROM products p JOIN shops s ON p.shop_id = s.id WHERE s.owner_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{")
                    .append("\"id\":").append(rs.getInt("id")).append(",")
                    .append("\"name\":\"").append(rs.getString("name")).append("\",")
                    .append("\"description\":\"").append(rs.getString("description")).append("\",")
                    .append("\"price\":").append(rs.getDouble("price")).append(",")
                    .append("\"isAvailable\":").append(rs.getInt("is_available"))
                    .append("}");
                first = false;
            }
            json.append("]");
            out.print(json.toString());
        }
        conn.close();

    } catch (SQLException e) {
        e.printStackTrace();
    }
}

    // POST - add a new product
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("http://localhost:8080/DoorMart/login.html");
            return;
        }

        String name = request.getParameter("name");
        String description = request.getParameter("description");
        String price = request.getParameter("price");
        String action = request.getParameter("action");

        try {
            Connection conn = DBConnection.getConnection();

            // Get shop id for this owner
            String shopSql = "SELECT id FROM shops WHERE owner_id = ?";
            PreparedStatement shopPs = conn.prepareStatement(shopSql);
            shopPs.setInt(1, userId);
            ResultSet shopRs = shopPs.executeQuery();

            if (shopRs.next()) {
                int shopId = shopRs.getInt("id");

                if (action != null && action.equals("toggle")) {
                    // Toggle availability
                    int productId = Integer.parseInt(request.getParameter("productId"));
                    String toggleSql = "UPDATE products SET is_available = NOT is_available WHERE id = ?";
                    PreparedStatement togglePs = conn.prepareStatement(toggleSql);
                    togglePs.setInt(1, productId);
                    togglePs.executeUpdate();
                } else {
                    // Add new product
                    String sql = "INSERT INTO products (shop_id, name, description, price) VALUES (?, ?, ?, ?)";
                    PreparedStatement ps = conn.prepareStatement(sql);
                    ps.setInt(1, shopId);
                    ps.setString(2, name);
                    ps.setString(3, description);
                    ps.setDouble(4, Double.parseDouble(price));
                    ps.executeUpdate();
                }
            }
            conn.close();
            response.sendRedirect("http://localhost:8080/DoorMart/owner/dashboard.jsp");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}