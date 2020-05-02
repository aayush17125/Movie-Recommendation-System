import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class Investor {
    static String fname, lname, address, phn, postal, email, password;
    static int id, aid;
    static Scanner sc = new Scanner(System.in);
    static Connection conn;
    public Investor(int id, Connection c){
        this.id = id;
        conn = c;
        String query = "Select * from investor where investor_id = ?";
        //execute this query
        try {
//            System.out.println("In try block"            );
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1,id);
            ResultSet rs =ps.executeQuery();
//             ps.getGeneratedKeys();
            while(rs.next()){
                fname = rs.getString("first_name");
                lname = rs.getString("last_name");
                System.out.println("Welcome "+fname);
                email = rs.getString("email");
//                username = rs.getString("username");
                password = rs.getString("password");
                aid = rs.getInt("addr_id");
            }
            String addr2 = "Select * from addr where addr_id = ?";
            ps = conn.prepareStatement(addr2);
            ps.setInt(1,aid);
            rs = ps.executeQuery();
//            rs = ps.getGeneratedKeys();
            while(rs.next()){
                address = rs.getString("address");
                phn = rs.getString("phone");
                postal = rs.getString("postal_code");
            }
        } catch (SQLException e) {
            System.out.println("Something went wrong in fetching users data, error: "+e.toString());
        }

        inputChoice();
    }
    public static void EmployeeChart(){
        System.out.println("***********************************************************************************");
        System.out.println("*                      Welcome to DVD RENTAL STORE                                *");
        System.out.println("***********************************************************************************");
        System.out.println("*\t(1) Press 1 to Display your total investments made                             *");
        System.out.println("*\t(2) Press 2 to Display your investments on a day/month/year wise               *");
        System.out.println("*\t(3) Press 3 to Display total sales in day                                      *");
        System.out.println("*\t(4) Press 4 to Display total sales in month                                    *");
        System.out.println("*\t(5) Press 5 to Display total sales in year                                     *");
        System.out.println("*\t(6) Press 6 to Display total sales of all movies                               *");
        System.out.println("*\t(7) Press 7 to Display demanding categories                                    *");
        System.out.println("*\t(8) Press 8 to Edit your Details                                               *");
        System.out.println("*\t(9) Press 9 to Make an Investment                                              *");
        System.out.println("*\t(10) Press 0 to EXIT/LOGOUT                                                    *");
        System.out.println("***********************************************************************************");
        System.out.print("Input your choice: ");
    }
    public static void inputChoice(){
        int i = -1;
        do{
            EmployeeChart();
            String choice = sc.nextLine();
            try{
                i = Integer.parseInt(choice);
                switch (i){
                    case 0:  return;
                    //todo: showing null totalInvestment()
                    case 1:  totalInvestment(); break;
                    case 2:  totalInvestmentFY();  break;
                    case 3:  Admin.TotalSalesFD();  break;
                    case 4:  Admin.TotalSalesFM();   break;
                    case 5:  Admin.TotalSalesFY();   break;
                    case 6:  Admin.salesByMovie(); break;
                    case 7:  Admin.SalesByCategory(); break;
                    case 8:  editInvestorDetails(); break;
                    case 9: MakeInvestment(); break;
                    default: System.out.println("Enter valid input");
                }
            }catch(Exception e){
                System.out.println("Please enter a valid number");
            }

        }while(i!=0);
    }

    private static void MakeInvestment() {
        System.out.println("Enter amount: ");
        String s = sc.nextLine();
        int f = -1;
        try{
             f = Integer.parseInt(s);
        }catch (Exception e){
            System.out.println("Please enter valid integer");
            return;
        }
        if(f<0) {
            System.out.println("Investment can't be negative");
            return;
        }
        try {
            String investment = "insert into investment(investor_id,amount,payment_date) values( ?,?,?)";
            PreparedStatement ps = conn.prepareStatement(investment);
            ps.setInt(1, id);
            ps.setInt(2, f);
            //get current time
            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
            LocalDateTime now = LocalDateTime.now();
            String stamp = dtf.format(now);
            ps.setString(3, stamp);
            ps.executeUpdate();
            System.out.println("Investor added successfully! press any key to return to previous menu");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong, error: "+e.toString());
        }
    }

    private static void editInvestorDetails() {
        System.out.println("Your current details are as follows\n" +
                "First Name: "+fname+"\n" +
                "Last Name:  "+lname+"\n" +
//                "username:   "+username+"\n" +
                "address:    "+address+"\n" +
                "phone:      "+phn+"\n" +
                "postal:     " +postal);
        System.out.println("Press 1 to change Name\nPress 2 change Address and postal\nPress 3 to change phone No.\n" +
                "Press 4 to change password\nPress any other key to return to previous menu");
        String ch = sc.nextLine();
        if(ch.equals("1")){
            //change name
            System.out.print("Enter first name: ");
            String fn = sc.nextLine();
            System.out.print("Enter Last name: ");
            String ln = sc.nextLine();
            if(fn.length()<3||ln.length()<3){
                System.out.println("Length too small, press any key to return to previous menu");
                sc.nextLine();
            }
            //Update here
            String query2 = "UPDATE investor\n" +
                    "SET first_name = ?, last_name = ? \n" +
                    "WHERE investor_id = ? \n";
            try {
                PreparedStatement ps = conn.prepareStatement(query2);
                ps.setString(1, fn);
                ps.setString(2, ln);
                ps.setInt(3,id);
                ps.executeUpdate();
                System.out.println("Update Success");
                fname = fn;
                lname = ln;
                System.out.println("Press any key to continue");
                sc.nextLine();
            } catch (Exception e) {
                System.out.println("Something went wrong, error: "+e.toString());
            }
        }else if(ch.equals("2")){
            //update address and postal
            System.out.println("Change your Address");
            String nadd, npost;
            System.out.print("Enter new Address: ");
            nadd = sc.nextLine();
            System.out.print("Enter new Postal: ");
            npost = sc.nextLine();
            if(npost.length()!=6 || !npost.matches("[0-9]+")){
                System.out.println("Invalid postal, press any key to return to previous menu");
                sc.nextLine();
            }
            ///////////////////////////////////////////////////////////////////////////////////////////////////
            String query2 = "UPDATE addr\n" +
                    "SET address = ? , postal_code = ? \n" +
                    "WHERE addr_id = ? \n";
            try {
                PreparedStatement ps = conn.prepareStatement(query2);
                ps.setString(1, nadd);
                ps.setInt(3, aid);
                ps.setString(2, npost);
                ps.executeUpdate();
                System.out.println("Address successfully updated");
                address = nadd;
                postal = npost;
                System.out.println("Press any key to continue");
                sc.nextLine();
            } catch (Exception e) {
                System.out.println("Something went wrong, error: "+e.toString());
            }
        }else if(ch.equals("3")){
            System.out.println("Enter new Phone no.: ");
            String phno = sc.nextLine();
            if(phno.length()!=10 || !phno.matches("[0-9]+")){
                System.out.println("Invalid Phone no., returning to previous menu");
                return;
            }
            ////////////////////////////////////////////////////////////////////////////////////////////////
            String query3 = "UPDATE addr\n" +
                    "SET phone = ?\n" +
                    "WHERE addr_id = ? \n";
            try {
                PreparedStatement ps = conn.prepareStatement(query3);
                ps.setString(1, phno);
                ps.setInt(2, aid);
                ps.executeUpdate();
                System.out.println("Phone no. successfully updated");
                phn = phno;
                System.out.println("Press any key to continue");
                sc.nextLine();
            } catch (Exception e) {
                System.out.println("Something went wrong, error: "+e.toString());
            }
            //todo for password
        }else if(ch.equals("4")){
            //change Password
            String pass;
            System.out.print("Enter old password:");
            String temp_pass = sc.nextLine();
            temp_pass = Movie.pashash(temp_pass);
            if(!temp_pass.equals(password)){
                System.out.println("Old password does not match, press any key to return to previous menu");
                sc.nextLine();
                return;
            }
            System.out.println("Enter new password");
            pass  = sc.nextLine();
            pass = Movie.pashash(pass);
            if(pass.length()<3){
                System.out.println("Password length too short, press any key to return to previous menu");
                sc.nextLine();
                return;
            }

            try {
                String query3 = "UPDATE investor\n" +
                        "SET password = ?\n" +
                        "WHERE investor_id = ? \n";
                PreparedStatement ps = conn.prepareStatement(query3);
                ps.setString(1, pass);
                ps.setInt(2, id);
                ps.executeUpdate();
                System.out.println("Password successfully updated");
                password = pass;
            } catch (Exception e) {
                System.out.println("Something went wrong, error: "+e.getStackTrace().toString());

            }

        }else{
            return;
        }
    }

    public static void totalInvestment(){
//        System.out.println("ID= "+id);
        String q = "select amount, payment_date Date from investment where investor_id = ?";
        try {
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setInt(1, id);
            ResultSet rs = ps.executeQuery();
            String[] arr = new String[]{"AMOUNT", "Date"};
            List<String[]> lis = new ArrayList<>();
            lis.add(arr);
            while(rs.next()){
//                System.out.println("Adding data");
                String[] ar = new String[2];
                int i =0;
                ar[i++] = ""+rs.getInt("amount");
//                System.out.println("arr:"+ar[i-1]);
                ar[i++] = rs.getString("Date");
                lis.add(ar);
            }
            Movie.customTabPrint(lis);
//            System.out.println("My print:  "+lis.get(1)[0]);
            System.out.println("**************************END OF RESULT*********************************");
            System.out.println("Press any key for previous menu");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong "+e.toString());
        }
    }
    public static void totalInvestmentFY(){
        System.out.println("Note: to calc. year, only specify year(YYYY) only and for month YYYY-MM and for date (YYYY-MM-DD)");
        System.out.print("Enter year/month/date to get total Investments: ");
        String year = sc.nextLine();
        String q = "Select sum(amount) as sum from investment where investor_id = ? and payment_date like ?";
        try{
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setInt(1,id);
            ps.setString(2, year+"%");
            ResultSet rs = ps.executeQuery();
            String fund = "0";
            while(rs.next()){
                fund = rs.getString("sum");
            }
            System.out.println("Total Investment made: "+fund+" Press any key to continue");
            sc.nextLine();
        }catch (Exception e){
            System.out.println("Something went wrong!, error: "+e.toString());
        }
    }

}
