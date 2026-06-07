/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package com.doormart.doormart;



import java.io.*;
import java.sql.*;
import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

@WebServlet("/RegisterServlet")
public class RegisterServlet extends HttpServlet {

    @Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String name = request.getParameter("name");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String role = request.getParameter("role");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");

        try {
            Connection conn = DBConnection.getConnection();
            
            // Check if email already exists
            String checkSql = "SELECT id FROM users WHERE email = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, email);
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next()) {
                // Email already exists
                response.sendRedirect("http://localhost:8080/DoorMart/register.html?success=registered");
            } else {
                // Insert new user
                String sql = "INSERT INTO users (name, email, password, role, phone, address) VALUES (?, ?, ?, ?, ?, ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setString(1, name);
                ps.setString(2, email);
                ps.setString(3, password);
                ps.setString(4, role);
                ps.setString(5, phone);
                ps.setString(6, address);
                ps.executeUpdate();
                conn.close();
                response.sendRedirect("http://localhost:8080/DoorMart/register.html?success=registered");
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("http://localhost:8080/DoorMart/register.html?error=failed");
        }
    }
}