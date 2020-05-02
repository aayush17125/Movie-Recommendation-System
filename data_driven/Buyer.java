import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.security.spec.ECField;
import java.sql.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.Scanner;
public class Buyer {
    public static Statement stmt;
    public static Connection conn;
    public static String first, last, stamp, address, postal, phone, email, password;
    public static int id, addr_id;
    public static Scanner sc = new Scanner(System.in);
    public Buyer(int bid, Statement stmt, Connection connection){
        this.id = bid;
        this.conn = connection;
        Buyer.stmt = stmt;
        String query = "Select * from buyer where buyer_id = ?";
        //execute this query
        try {
//            System.out.println("In try block"            );
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setInt(1,id);
            ResultSet rs =ps.executeQuery();
//             ps.getGeneratedKeys();
            while(rs.next()){
                first = rs.getString("first_name");
                last = rs.getString("last_name");
                System.out.println("Welcome "+first);
                email = rs.getString("email");
                stamp = rs.getString("create_date");
                addr_id = rs.getInt("addr_id");
            }
            String addr2 = "Select * from addr where addr_id = ?";
            ps = conn.prepareStatement(addr2);
            ps.setInt(1,addr_id);
            rs = ps.executeQuery();
//            rs = ps.getGeneratedKeys();
            while(rs.next()){
                address = rs.getString("address");
                phone = rs.getString("phone");
                postal = rs.getString("postal_code");
            }
        } catch (SQLException e) {
            System.out.println("Something went wrong in fetching users data, error: "+e.toString());
        }
        /////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    }

    public static void printUserMainScreen(){
        System.out.println("***********************************************************************************");
        System.out.println("*                      Welcome to DVD RENTAL STORE                                *");
        System.out.println("***********************************************************************************");
        System.out.println("*\t(1) Press 1 to View All Movies                                                *");
        System.out.println("*\t(2) Press 2 to Search Movies                                                  *");
        System.out.println("*\t(3) Press 3 to get Recommendations                                            *");
        System.out.println("*\t(4) Press 4 to find name of actors in a movie                                 *");
        System.out.println("*\t(5) Press 5 to find movies having duration less than custom duration          *");
        System.out.println("*\t(6) Press 6 to edit your details                                              *");
        System.out.println("*\t(7) Press 7 to find your orders                                               *");
        System.out.println("*\t(8) Press 8 to find your active movies                                        *");
        System.out.println("*\t(0) Press 0 to EXIT/Logout                                                    *");
        System.out.println("***********************************************************************************");
    }

    public static void inputMainChoice(){
        int i = -1;
        do{
            printUserMainScreen();
            System.out.println("Enter your CHOICE");
            String in = sc.nextLine();
            try{
                i = Integer.parseInt(in);
                switch(i){
                    case 1: ViewAllMovies(); break;
                    case 2: searchMovies(); break;
                    case 3: ViewRecommendations();break;
                    case 4: NameofActor(); break;
                    case 5: CustomDuration(); break;
                    case 6: EditDetails(); break;
                    case 7: AllOrders(); break;
                    case 8: ActiveOrder(); break;
//                    case 9: boolean temp = DeleteAccount(); if(temp)return; break;
                    case 0: break;
                    default:System.out.println("Please enter a valid choice");break;
                }
            }catch (Exception e){
                System.out.println("Please enter a valid choice");
            }
        }while(i!=0);
    }
    public static void ViewAllMovies(){
        String query = "Select * from movie_list order by FID ";
        try {
            ResultSet rs = stmt.executeQuery(query);
            List<String[]> lis = new ArrayList<>();
            String[] sarr2 =new String[]{"ID","TITLE","CATEGORY","PRICE","LENGTH","RATINGS","ACTORS"};
            lis.add(sarr2);
            while(rs.next()){
                String[] sarr = new String[7];
                int i =0;
                sarr[i++] = ""+rs.getInt("FID");
                sarr[i++] = rs.getString("title");
                sarr[i++] = rs.getString("category");
                sarr[i++] = rs.getString("price");
                sarr[i++] = rs.getString("length");
                sarr[i++] = rs.getString("rating");
                sarr[i++] = rs.getString("actors");
                lis.add(sarr);
            }
            Movie.customTabPrint(lis);
            System.out.println("want to rent some movies?(Y/N)");
            String ans = sc.nextLine();
            if(ans.toLowerCase().equals("n"))return;
            if(ans.toLowerCase().equals("y")){
                buyMovie();
            }else {
                System.out.println("Invalid Choice, returning to previous menu");return;
            }
        } catch (SQLException e) {
            System.out.println("Something Went Wrong, error: "+e.toString());
        }
    }



    public static void searchMovies(){
        //Search movies by names, actors, date and sort then by price
        System.out.println("***********************************************************************************");
        System.out.println("*                      Enter your choice to search DVDs                           *");
        System.out.println("***********************************************************************************");
        System.out.println("*\t(1) Press 1 to search by name                                                *");
        System.out.println("*\t(2) Press 2 to search by actor                                               *");
        System.out.println("*\t(3) Press 3 to search by category                                            *");
        System.out.println("*\t(0) Press 0 to EXIT                                                          *");
        System.out.println("***********************************************************************************");
        System.out.print("Enter your choice: ");
        String ch = sc.nextLine();
        if(ch.equals("1")){
            //search by name
            System.out.print("Please enter Name: ");
            String name = sc.nextLine();
            String query = "Select * from movie_list where title like ? ";
            try {
//                System.out.println("In try block");
                PreparedStatement ps = conn.prepareStatement(query);
                ps.setString(1, name+"%");
//                System.out.println("before executing");
                ResultSet rs  = ps.executeQuery();
                List<String[]> lis = new ArrayList<>();

                String[] sarr2 =new String[]{"ID",   "TITLE",        "CATEGORY",       "PRICE",       "LENGTH",      "RATINGS",       "ACTORS"};
                lis.add(sarr2);
                int count = 0;
                while(rs.next()){
                    int i = 0;
                    count++;
                    String[] sarr = new String[7];
                    sarr[i++] = ""+rs.getInt("FID");
                    sarr[i++] = rs.getString("title");
                    sarr[i++] = rs.getString("category");
                    sarr[i++] = rs.getString("price");
                    sarr[i++] = rs.getString("length");
                    sarr[i++] = rs.getString("rating");
                    sarr[i++] = rs.getString("actors");
                    lis.add(sarr);
                }
                System.out.println("************************************************************************************");
                Movie.customTabPrint(lis);
                System.out.println("************************************************************************************");
                if(count>0){

                    System.out.println("want to rent some movies?(Y/N)");
                    String ans = sc.nextLine();
                    if(ans.toLowerCase().equals("n"))return;
                    if(ans.toLowerCase().equals("y")){
                        buyMovie();
                    }else {
                        System.out.println("Invalid Choice, returning to previous menu");return;
                    }
                }
            } catch (SQLException e) {
                System.out.println("Something went wrong in searching movies err: "+e.toString());
            }
        }else if(ch.equals("2")){
            //Search by actor
            System.out.print("Please enter Actor's first name: ");
            String ac_fname  = sc.nextLine();
            System.out.print("Please enter Actor's last name: ");
            String ac_lname = sc.nextLine();
            String query = "select  title, movie_id, rental_rate, release_year, rating, rental_duration from movie where movie_id in \n" +
                    "                    ( select movie_id from movie_actor where actor_id in \n" +
                    "                    (select actor_id from actor where first_name = ? and last_name = ?) )";
            try {
//                System.out.println(conn);
                PreparedStatement ps = conn.prepareStatement(query);
                ps.setString(1, ac_fname);
                ps.setString(2, ac_lname);
                ResultSet rs = ps.executeQuery();
//                System.out.println("after exe");

                ArrayList<String[]> lis = new ArrayList<>();
                String[] arr2 = new String[]{"ID", "TITLE", "RELEASE_YEAR", "RATINGS", "PRICE","DURATION"};
                lis.add(arr2);

                int count = 0;
                while(rs.next()){
                    int i =0;
                    String[] arr = new String[6];
                    count++;
                    arr[i++] = ""+rs.getInt("movie_id");
                    arr[i++] = rs.getString("title");
                    arr[i++] = rs.getString("release_year");
                    arr[i++] = rs.getString("rating");
                    arr[i++] = rs.getString("rental_rate");
                    arr[i++] = rs.getString("rental_duration");
                    lis.add(arr);
                }
                Movie.customTabPrint(lis);
                System.out.println("************************END OF RESULT**********************************");

                if(count>0){
                    System.out.println("want to rent some movies?(Y/N)");
                    String ans = sc.nextLine();
                    if(ans.toLowerCase().equals("n"))return;
                    if(ans.toLowerCase().equals("y")){
                        buyMovie();
                    }else {
                        System.out.println("Invalid Choice, returning to previous menu");return;
                    }
                }

            } catch (Exception e) {
                System.out.println("Something went wrong, error: "+e.toString());
            }
        }else if(ch.equals("3")){
            //search by category
            System.out.print("Enter Category name: ");
            String category_name = sc.nextLine();
            String query2 = "select movie_id, title, release_year ,rating,rental_rate, rental_duration from movie\n" +
                    "where movie_id in (select movie_id from movie_category\n" +
                    "where category_id in (select category_id from category where name = ? ))";
            try {
                PreparedStatement ps = conn.prepareStatement(query2);
                System.out.println("in try");
                ps.setString(1, category_name);
//                ps.setString(2, "bbb");
//                System.out.println("after set string");
                ResultSet rs = ps.executeQuery();
//                System.out.println("After execution");
                ArrayList<String[]> lis = new ArrayList<>();
                String[] arr2 = new String[]{"ID", "TITLE", "RELEASE_YEAR", "RATINGS", "PRICE","DURATION"};
                lis.add(arr2);
                int count = 0;
                while (rs.next()){
                    int i =0;
                    String[] arr = new String[6];
                    count++;
                    arr[i++] = ""+rs.getInt("movie_id");
                    arr[i++] = rs.getString("title");
                    arr[i++] = rs.getString("release_year");
                    arr[i++] = rs.getString("rating");
                    arr[i++] = rs.getString("rental_rate");
                    arr[i++] = rs.getString("rental_duration");
                    lis.add(arr);
                }
                Movie.customTabPrint(lis);
                System.out.println("************************END OF RESULT**********************************");

                System.out.println("want to rent some movies?(Y/N)");
                String ans = sc.nextLine();
                if(ans.toLowerCase().equals("n"))return;
                if(ans.toLowerCase().equals("y")){
                    buyMovie();
                }else {
                    System.out.println("Invalid Choice, returning to previous menu");return;
                }
            } catch (Exception e) {
                System.out.println("Something went wrong "+e.toString());
            }
        }
    }
    public static void NameofActor(){
        System.out.print("Enter movie's name: ");
        String s = sc.nextLine();
        String q = "select first_name, last_name \n" +
                "from actor\n" +
                "where actor_id in (\n" +
                "select actor_id\n" +
                "from movie_actor\n" +
                "where movie_id in (\n" +
                "select movie_id from movie where lower(title) = lower( ? )\n" +
                ")\n" +
                ");\n";
        try {
//            System.out.println("in try,"+s);
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setString(1, s);
//            System.out.println("After exe");
            ResultSet rs = ps.executeQuery();
            ArrayList<String[]> lis = new ArrayList<>();
            String[] arr2 = new String[]{"First Name", "Last Name"};
            lis.add(arr2);

            int count = 0;
            while (rs.next()){
                int i =0;
                String[] arr = new String[2];
                count++;
                arr[i++] = rs.getString("first_name");
                arr[i++] = rs.getString("last_name");
                lis.add(arr);
            }
            Movie.customTabPrint(lis);
            System.out.println("************************END OF RESULT**********************************");
            System.out.println("Press any key to move to previous menu");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong, error: "+e.toString());
        }
    }
    public static void CustomDuration(){
        System.out.print("Enter max duration: ");
        String dur = sc.nextLine();
        String query = "select movie_id, title, length, rental_rate, rating\n" +
                "from movie\n" +
                "Where length< ? \n" +
                "order by length desc";
        try {
            PreparedStatement ps = conn.prepareStatement(query);
            ps.setString(1, dur);
            ResultSet rs = ps.executeQuery();
            ArrayList<String[]> lis = new ArrayList<>();
            String[] arr2 = new String[]{"ID", "TITLE", "RATINGS", "PRICE","DURATION"};
            lis.add(arr2);

            int count = 0;
            while (rs.next()){
                int i =0;
                String[] arr = new String[5];
                count++;
                arr[i++] = ""+rs.getInt("movie_id");
                arr[i++] = rs.getString("title");
                arr[i++] = rs.getString("rating");
                arr[i++] = rs.getString("rental_rate");
                arr[i++] = rs.getString("length");
                lis.add(arr);
            }
            Movie.customTabPrint(lis);
            System.out.println("************************END OF RESULT**********************************");
            if(count>0){
                System.out.println("want to rent some movies?(Y/N)");
                String ans = sc.nextLine();
                if(ans.toLowerCase().equals("n"))return;
                if(ans.toLowerCase().equals("y")){
                    buyMovie();
                }else {
                    System.out.println("Invalid Choice, returning to previous menu");return;
                }
            }
        } catch (Exception e) {
            System.out.println("Something went wrong, error: "+e.toString());
        }
    }
    public static void EditDetails(){
        System.out.println("***********************************************************************************");
        System.out.println("*                                 Welcome                                         *");
        System.out.println("*\tYour Current details are as follows                                           *");
        System.out.println("*\tFirst Name:     "+first);
        System.out.println("*\tLast name Name: "+last);
        System.out.println("*\tEmail Address:  "+email);
        System.out.println("*\tContact No.:    "+phone);
        System.out.println("*\tAddress:        "+address);
        System.out.println("***********************************************************************************");
        System.out.println("\n*\t(1) Press 1 to Edit First Name                                              *");
        System.out.println("*\t(2) Press 2 to Edit Phone                                                     *");
        System.out.println("*\t(3) Press 3 to Edit Address                                                     *");
        System.out.println("*\t(*) Press any button to return to previous menu                               *");
        System.out.println("***********************************************************************************");
        System.out.print("Enter your choice");
        String ch = sc.nextLine();
        if(ch.equals("1")){
            System.out.println("Enter New Name");
            String newName = sc.nextLine();
            if(newName.length()<3){
                System.out.println("Too short name, please try again");
                return;
            }
            System.out.println("Enter name: "+newName);
            //////////////////////////////////////////////////////////////////////////////////////////
            String query2 = "UPDATE buyer\n" +
                    "SET first_name = ? \n" +
                    "WHERE buyer_id = ? \n";
            try {
                PreparedStatement ps = conn.prepareStatement(query2);
                ps.setString(1, newName);
                ps.setInt(2,id);
                ps.executeUpdate();
                System.out.println("Update Success");
                first = newName;
                System.out.println("Press any key to move to previous menu");
                sc.nextLine();
            } catch (Exception e) {
                System.out.println("Something went wrong, error: "+e.getStackTrace());
            }
            //////////////////////////////////////////////////////////////////////////////////////////
        }else if(ch.equals("2")){
            System.out.println("Enter new Phone no.: ");
            String phn = sc.nextLine();
            if(phn.length()!=10){
                System.out.println("Invalid Phone no., returning to previous menu");
                return;
            }
            ////////////////////////////////////////////////////////////////////////////////////////////////
            String query3 = "UPDATE addr\n" +
                    "SET phone = ?\n" +
                    "WHERE addr_id = ? \n";
            try {
                PreparedStatement ps = conn.prepareStatement(query3);
                ps.setString(1, phn);
                ps.setInt(2, addr_id);
                ps.executeUpdate();
                System.out.println("Phone no. successfully updated");
                phone = phn;
                System.out.println("Press any key to move to previous menu");
                sc.nextLine();
            } catch (Exception e) {
                System.out.println("Something went wrong, error: "+e.toString());

            }


            /////////////////////////////////////////////////////////////////////////////////////////////////
        }else if(ch.equals("3")){
            System.out.println("Change your Address");
            String nadd, npost;
            System.out.print("Enter new Address: ");
            nadd = sc.nextLine();
            System.out.print("Enter new Postal: ");
            npost = sc.nextLine();

            if(npost.length()!=6 || !npost.matches("[0-9]+")){
                System.out.println("Invalid Postal, returning to previous menu");
                return;
            }
            ///////////////////////////////////////////////////////////////////////////////////////////////////
            String query2 = "UPDATE addr\n" +
                    "SET address = ? , postal_code = ? \n" +
                    "WHERE addr_id = ? \n";
            try {
                PreparedStatement ps = conn.prepareStatement(query2);
                ps.setString(1, nadd);
                ps.setInt(3, addr_id);
                ps.setString(2, npost);
                ps.executeUpdate();
                System.out.println("Address successfully updated");
                address = nadd;
                postal = npost;
                System.out.println("Press any key to move to previous menu");
                sc.nextLine();
            } catch (Exception e) {
                System.out.println("Something went wrong, error: "+e.getStackTrace().toString());
            }
        }else return;
    }

    public static void ViewRecommendations(){
        try{
            Process p = Runtime.getRuntime().exec("python ml.py "+"root"+" "+email);
            BufferedReader in = new BufferedReader(new InputStreamReader(p.getInputStream()));
            String ret =in.readLine();
//            ret = in.readLine();
//            System.out.println(ret);
            String q = "Select * from movie_list where FID in "+ret;
            try {
                PreparedStatement ps = conn.prepareStatement(q);
//                ps.setString(1, ret);
                ResultSet rs = ps.executeQuery();
                ArrayList<String[]> lis = new ArrayList<>();
                String[] arr2 = new String[]{"ID", "TITLE", "CATEGORY", "PRICE", "DURATION","RATINGS","ACTORS"};
                lis.add(arr2);
                int count = 0;
                while (rs.next()) {
                    int i = 0;
                    String[] arr = new String[7];
                    count++;
                    arr[i++] = "" + rs.getInt(i);
                    arr[i++] = rs.getString(i);
                    arr[i++] = rs.getString(i);
                    arr[i++] = rs.getString(i);
                    arr[i++] = rs.getString(i);
                    arr[i++] = rs.getString(i);
                    arr[i++] = rs.getString(i);
                    lis.add(arr);
                }
                Movie.customTabPrint(lis);
                System.out.println("************************END OF RESULT**********************************");
                if(count>0){
                    System.out.println("want to rent some movies?(Y/N)");
                    String ans = sc.nextLine();
                    if(ans.toLowerCase().equals("n"))return;
                    if(ans.toLowerCase().equals("y")){
                        buyMovie();
                    }else {
                        System.out.println("Invalid Choice, returning to previous menu");return;
                    }
                }
            }catch (Exception e){
                System.out.println("Something went wrong error: "+e.toString());
            }


        }catch(Exception e){
            e.getStackTrace();
            System.out.println(e.toString());
        }

        //by Ayush

    }


    public static void AllOrders(){
        String q = "select title, movie_id from movie where movie_id in(\n" +
                "\tselect movie_id from rental where buyer_id = ? \n" +
                ")";
        try {
            PreparedStatement ps = conn.prepareStatement(q);
            ps.setInt(1,id);
//            System.out.println("after set string");
            ResultSet rs = ps.executeQuery();
//            System.out.println("After execution");
            ArrayList<String[]> lis = new ArrayList<>();
            String[] arr2 = new String[]{"ID", "TITLE"};
            lis.add(arr2);

            int count = 0;
            while (rs.next()){
                int i =0;
                String[] arr = new String[2];
                count++;
                arr[i++] = ""+rs.getInt("movie_id");
                arr[i++] = rs.getString("title");
                lis.add(arr);
            }
            Movie.customTabPrint(lis);
            System.out.println("************************END OF RESULT**********************************");
            System.out.println("Press any key to move to previous menu");
            sc.nextLine();
        } catch (Exception e) {
            System.out.println("Something went wrong:"+e.toString());
        }
    }
    public static void ActiveOrder(){
        String q =  "select m.movie_id, title, return_date from movie m, rental r where r.movie_id = m.movie_id and buyer_id = ? and return_date>?";
//        System.out.println("after set string");
        PreparedStatement ps  = null;
        try {
            ps = conn.prepareStatement(q);
            ps.setInt(1, id);
            //get current time
            DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
            LocalDateTime now = LocalDateTime.now();
            String today = dtf.format(now);
            ps.setString(2, today);
            ResultSet rs = ps.executeQuery();
//            System.out.println("After execution");
            ArrayList<String[]> lis = new ArrayList<>();
            String[] arr2 = new String[]{"ID", "TITLE"};
            lis.add(arr2);

            int count = 0;
            while (rs.next()) {
                int i = 0;
                String[] arr = new String[2];
                count++;
                arr[i++] = "" + rs.getInt("movie_id");
                arr[i++] = rs.getString("title");
                lis.add(arr);
            }
            Movie.customTabPrint(lis);
            System.out.println("************************END OF RESULT**********************************");
            System.out.println("Press any key to go to previous menu");
            sc.nextLine();
        }catch (Exception e) {
            System.out.println("Something went wrong "+e.toString());
        }

    }
    private static boolean DeleteAccount(){
        boolean flag = false;
        System.out.print("Are you sure you want to DELETE YOUR ACCOUNT? (Y/N): ");
        String ans = sc.nextLine();
        if(ans.toLowerCase().equals("n")){
            System.out.println("this friendship should last forever");
        }else{
            String q = "DELETE FROM buyer WHERE buyer_id = ? ";
            String q2 = "DELETE FROM addr WHERE addr_id = ? ";
            try {
                PreparedStatement ps = conn.prepareStatement(q);
                ps.setInt(1, id);
                ps.executeUpdate();
                ps = conn.prepareStatement(q2);
                ps.setInt(1, addr_id);
                ps.executeUpdate();
                System.out.println("User deletion Successful");
                System.out.println("is so hard to leave—until you leave. ...");
                flag = true;
                System.out.println("Press any button to continue");
                sc.nextLine();
            } catch (Exception e) {
                System.out.println("Something went wrong, error: "+e.toString());
            }
        }
        return flag;
    }

    public static void buyMovie(){
        int i = -1;
        do{
            System.out.println("Enter ID of movie to buy");
            String ch = sc.nextLine();
            System.out.print("Enter preferred Employee ID, if none, enter 1: ");
            String eiid  =sc.nextLine();
            int emp_id = -1;
//            int ch = -1;
            try{
                int mid = Integer.parseInt(ch);
                emp_id = Integer.parseInt(eiid);
                DateTimeFormatter dtf = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");
                LocalDateTime now = LocalDateTime.now();
                String today = dtf.format(now);
                if(emp_id==-1){
                    System.out.println("Employee ID is invalid, returning to previous screen");return;
                }
                //get the return date from movies database
                String getReturnDate = "select rental_duration, rental_rate from movie where movie_id = ?";
                PreparedStatement ps = conn.prepareStatement(getReturnDate);
                ps.setInt(1,mid);
                ResultSet rs = ps.executeQuery();
                int duration  = -1;
                double price = 0;
                boolean exists = false;
//                System.out.println("After execution");
                while (rs.next()){
                    exists = true;
                    duration = rs.getInt("rental_duration");
                    price = (double)rs.getDouble("rental_rate");
                }
                if(exists){
                    //get the return date
//                    System.out.println("Exists");
                    DateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
                    Calendar cal = Calendar.getInstance();
                    cal.add(Calendar.DATE, duration);
                    Date todate1 = cal.getTime();
                    String fromdate = dateFormat.format(todate1);
//                    System.out.println(fromdate);
                    //Now write into tables
                    String query = "Insert into rental( rental_date, buyer_id, return_date, employee_id, movie_id)values(?,?,?,?,?)";
                    ps = conn.prepareStatement(query, Statement.RETURN_GENERATED_KEYS);
                    ps.setString(1,today);
                    ps.setInt(2,id);
                    ps.setString(3,fromdate);
                    ps.setInt(4,emp_id);
                    ps.setInt(5,mid);
                    ps.executeUpdate();
                    rs = ps.getGeneratedKeys();
//                    System.out.println("Generated key");
                    int rental_id = 0;
                    while (rs.next()){
                        rental_id = rs.getInt(1);
                    }
//                    System.out.println("rental: "+rental_id);
                    query = "Insert into payment( buyer_id, employee_id, rental_id, amount, payment_date)values(?,?,?,?,?)";
                    ps = conn.prepareStatement(query);
                    ps.setInt(1, id);
                    ps.setInt(2, emp_id);
                    ps.setInt(3,rental_id);
                    ps.setDouble(4, price);
                    ps.setString(5,today);
                    ps.executeUpdate();

                    System.out.println("Movie rented Successfully");
                }else{
                    System.out.println("Movie with specified ID doesnot exists");
                }
            }catch (Exception e){
                System.out.println("Not a valid ID: error ");
            }
            System.out.println("Press 1 to buy some more movies , Press any other button to return to previous menu");
            String val = sc.nextLine();
            if(!val.equals("1")){
                i = 0;
            }
        }while (i!=0);
    }





    //////////////////////////////////////////////////////////////
    //getters and setter

    public String getFirst() {
        return first;
    }

    public void setFirst(String first) {
        this.first = first;
    }

    public String getLast() {
        return last;
    }

    public void setLast(String last) {
        this.last = last;
    }

    public String getStamp() {
        return stamp;
    }

    public void setStamp(String stamp) {
        this.stamp = stamp;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getPostal() {
        return postal;
    }

    public void setPostal(String postal) {
        this.postal = postal;
    }

    public String getPhone() {
        return phone;
    }

    public void setPhone(String phone) {
        this.phone = phone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getAddr_id() {
        return addr_id;
    }

    public void setAddr_id(int addr_id) {
        this.addr_id = addr_id;
    }

}
