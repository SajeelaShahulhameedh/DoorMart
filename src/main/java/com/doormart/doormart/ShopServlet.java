package com.doormart.doormart;

import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet("/ShopServlet")
public class ShopServlet extends HttpServlet {

    // GET - check if owner has a shop
    @Override
protected void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    HttpSession session = request.getSession();
    Integer userId = (Integer) session.getAttribute("userId");

    if (userId == null) {
        response.sendRedirect("http://localhost:8080/DoorMart/login.html");
        return;
    }

    String action = request.getParameter("action");

    try {
        Connection conn = DBConnection.getConnection();
        response.setContentType("application/json");
        PrintWriter out = response.getWriter();

        if (action != null && action.equals("all")) {
            // Get all shops for customer
            String sql = "SELECT * FROM shops";
            PreparedStatement ps = conn.prepareStatement(sql);
            ResultSet rs = ps.executeQuery();

            StringBuilder json = new StringBuilder("[");
            boolean first = true;
            while (rs.next()) {
                if (!first) json.append(",");
                json.append("{")
                    .append("\"id\":").append(rs.getInt("id")).append(",")
                    .append("\"shopName\":\"").append(rs.getString("shop_name")).append("\",")
                    .append("\"description\":\"").append(rs.getString("description")).append("\",")
                    .append("\"phone\":\"").append(rs.getString("phone")).append("\",")
                    .append("\"address\":\"").append(rs.getString("address")).append("\"")
                    .append("}");
                first = false;
            }
            json.append("]");
            out.print(json.toString());

        } else {
            // Get shop for owner
            String sql = "SELECT * FROM shops WHERE owner_id = ?";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();

            if (rs.next()) {
                out.print("{\"hasShop\":true,\"shopId\":" + rs.getInt("id") + ",\"shopName\":\"" + rs.getString("shop_name") + "\"}");
            } else {
                out.print("{\"hasShop\":false}");
            }
        }
        conn.close();

    } catch (SQLException e) {
        e.printStackTrace();
    }
}

    // POST - create a new shop
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        Integer userId = (Integer) session.getAttribute("userId");

        if (userId == null) {
            response.sendRedirect("http://localhost:8080/DoorMart/login.html");
            return;
        }

        String shopName = request.getParameter("shop_name");
        String description = request.getParameter("description");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        try {
            Connection conn = DBConnection.getConnection();
            String sql = "INSERT INTO shops (owner_id, shop_name, description, phone, address) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, shopName);
            ps.setString(3, description);
            ps.setString(4, phone);
            ps.setString(5, address);
            ps.executeUpdate();
            conn.close();

            response.sendRedirect("http://localhost:8080/DoorMart/owner/dashboard.html");

        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}
