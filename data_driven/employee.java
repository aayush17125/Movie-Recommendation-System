import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class employee {
    static String fname, lname, address, phn, postal, email, username, password;
    static int id, aid;
    static Scanner sc = new Scanner(System.in);
    static Connection conn;
    public employee(int id, Connection c){
        this.id = id;
        conn = c;
        String query = "Select * from employee where employee_id = ?";
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
                username = rs.getString("username");
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
        System.out.println("*\t(1) Press 1 to Display your total referrals                                    *");
        System.out.println("*\t(2) Press 2 to Display your referrals on day/month/year                        *");
        System.out.println("*\t(3) Press 3 to Display your top 3 loyal buyer                                  *");
        System.out.println("*\t(4) Press 4 to Edit your details                                               *");
        System.out.println("*\t(5) Press 5 to view users registered on date                                   *");
        System.out.println("*\t(6) Press 6 to view sales of each movie                                        *");
        System.out.println("*\t(7) Press 0 to EXIT/LOGOUT                                                     *");
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
                    case 0: return;
                    case 1: totalrefers();  break;
                    case 2: referalOnDate();  break;
                    case 3:  top3();   break;
                    case 4: editYourDetails();  break;
                    case 5: userRegistered(); break;
                    case 6: Admin.salesByMovie();   break;
                    default: System.out.println("Enter valid input");
                }
            }catch(Exception e){
                System.out.println("Please enter a valid number");
            }
        }while(i!=0);
    }

    private static void referalOnDate() {
        System.out.println("Hint just add year/month to search no. of years added in that year/month");
        String q = "SELECT COUNT(*) 'Num of referrals',SUM(amount)\n" +
                "FROM payment where employee_id = ? and payment_date like ? ";
        System.out.print("Please enter date(YYYY-MM-DD): ");
        String date = sc.nextLine();

        try{
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setInt(1,id);
            ps.setString(2, date+"%");
            ResultSet rs = ps.executeQuery();
            String[] arr = new String[]{ "Name of Buyer", "Amount"};
            List<String[]> lis = new ArrayList<>();
            lis.add(arr);
            while(rs.next()){
                String[] ar = new String[2];
                int i =0;
                ar[i++] = rs.getString(1);
                if(ar[0]==null)ar[0] = " ";
//                System.out.println("dwata: "+ar[i-1]);
                ar[i++] = rs.getString("SUM(amount)");
                if(ar[1]==null)ar[1] = "0";
//                System.out.println("dwata: "+ar[i-1]);
                lis.add(ar);
            }
//            System.out.println("After something");
            Movie.customTabPrint(lis);
//            System.out.println("dwata: fsfaf");
            System.out.println("**************************END OF RESULT*********************************");
            System.out.println("Press any key to continue");
            sc.nextLine();
        }catch (Exception e){
            System.out.println("Something went wrong, error: "+e.toString());
        }

    }

    private static void top3() {
        String q  = "SELECT p.buyer_id,CONCAT(b.first_name,' ',b.last_name) 'Buyer Name',SUM(p.amount) 'Total Amount'\n" +
                "FROM payment p JOIN buyer b ON p.buyer_id=b.buyer_id\n" +
                "WHERE p.employee_id= ? \n" +
                "GROUP BY p.buyer_id\n" +
                "ORDER BY SUM(p.amount) desc\n" +
                "LIMIT 3";
        try{
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setInt(1,id);
            ResultSet rs = ps.executeQuery();
            String[] arr = new String[]{"Buyer_id", "Name of Buyer", "Amount"};
            List<String[]> lis = new ArrayList<>();
            lis.add(arr);
            while(rs.next()){
                String[] ar = new String[3];
                int i =0;
                ar[i++] = rs.getString(1);
//                System.out.println("dwata: "+arr[i-1]);
                ar[i++] = rs.getString(2);
                ar[i++] = rs.getString(3);
                lis.add(ar);
            }
            Movie.customTabPrint(lis);
            System.out.println("**************************END OF RESULT*********************************");
            System.out.println("Press any key to continue");
            sc.nextLine();
        }catch (Exception e){
            System.out.println("Something went wrong, error: "+e.toString());
        }
    }

    private static void totalrefers() {
        String q = "SELECT COUNT(*) 'Num of referrals',SUM(amount)\n" +
                "FROM payment where employee_id = ?";
        try{
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setInt(1,id);
            ResultSet rs = ps.executeQuery();
            String[] arr = new String[]{"Number of Referrals", "Amount"};
            List<String[]> lis = new ArrayList<>();
            lis.add(arr);
            while(rs.next()){
                String[] ar = new String[2];
                int i =0;
                ar[i++] = rs.getString(1);
//                System.out.println("dwata: "+ar[i-1]);
                if(ar[0]==null)ar[0] = "0";
                ar[i++] = rs.getString(2);
                if(ar[1]==null)ar[1] = "0";
//                System.out.println("Here");
                lis.add(ar);
            }
            Movie.customTabPrint(lis);
            System.out.println("**************************END OF RESULT*********************************");
            System.out.println("Press any key to continue");
            sc.nextLine();
        }catch (Exception e){
            System.out.println("Something went wrong, error: "+e.toString());
        }
    }

    public static void userRegistered() {
        System.out.println("Hint just add year/month to search no. of users added in that year/month");
        System.out.print("Enter date(YYYY-MM-DD)");
        String date = sc.nextLine();
        String q = "Select buyer_id,CONCAT(first_name,' ',last_name) from buyer where create_date like ?";
        try{
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setString(1,date+"%");
            ResultSet rs = ps.executeQuery();
            String[] arr = new String[]{"ID", "Name"};
            List<String[]> lis = new ArrayList<>();
            lis.add(arr);
            while(rs.next()){
                String[] ar = new String[2];
                int i =0;
                ar[i++] = rs.getString(1);
//                System.out.println("dwata: "+arr[i-1]);
                ar[i++] = rs.getString(2);
                lis.add(ar);
            }
            Movie.customTabPrint(lis);
            System.out.println("**************************END OF RESULT*********************************");
            System.out.println("Press any key to continue");
            sc.nextLine();
        }catch (Exception e){
            System.out.println("Something went wrong, error: "+e.toString());
        }
    }

    public static void editYourDetails() {
        System.out.println("Your current details are as follows\n" +
                "First Name: "+fname+"\n" +
                "Last Name:  "+lname+"\n" +
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
            String query2 = "UPDATE employee\n" +
                    "SET first_name = ?, last_name = ? \n" +
                    "WHERE employee_id = ? ";
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
                System.out.println("Something went wrong, error: "+e.getStackTrace().toString());
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
                System.out.println("Something went wrong, error: "+e.getStackTrace().toString());
            }
            //todo for password
        }else if(ch.equals("4")){
            //change Password
            String pass;
            System.out.print("Enter old password:");
            String temp_pass = sc.nextLine();
            if(!temp_pass.equals(password)){
                System.out.println("Old password does not match, press any key to return to previous menu");
                sc.nextLine();
                return;
            }
            System.out.println("Enter new password");
            pass  = sc.nextLine();
            if(pass.length()<3){
                System.out.println("Password length too short, press any key to return to previous menu");
                sc.nextLine();
                return;
            }
            try {
                String query3 = "UPDATE employee\n" +
                        "SET password = ?\n" +
                        "WHERE employee_id = ? \n";
                PreparedStatement ps = conn.prepareStatement(query3);
                pass = Movie.pashash(pass);
                ps.setString(1, pass);
                ps.setInt(2, id);
                ps.executeUpdate();
                System.out.println("Password successfully updated");
                password = pass;
                System.out.println("Press any key to continue");
                sc.nextLine();
            } catch (Exception e) {
                System.out.println("Something went wrong, error: "+e.getStackTrace().toString());
            }
        }else{
            return;
        }
    }
}
