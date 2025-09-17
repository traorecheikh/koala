import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:koala/app/data/models/models.dart';

part 'api_client.g.dart';

@RestApi(baseUrl: "https://api.monsuperapp.exemple")
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Auth
  @POST("/auth/login")
  Future<HttpResponse> login(@Body() Map<String, dynamic> body);

  // User
  @GET("/user")
  Future<User> getUser();

  @PUT("/user")
  Future<User> updateUser(@Body() Map<String, dynamic> body);

  // Accounts
  @GET("/accounts")
  Future<List<Account>> getAccounts();

  @POST("/accounts")
  Future<HttpResponse> createAccount(@Body() Map<String, dynamic> body);

  // Transactions
  @GET("/transactions")
  Future<List<Transaction>> getTransactions({
    @Query("from") String? from,
    @Query("to") String? to,
    @Query("category") String? category,
    @Query("page") int? page,
    @Query("per_page") int? perPage,
  });

  @POST("/transactions")
  Future<Transaction> createTransaction(@Body() Transaction transaction);

  @GET("/transactions/{id}")
  Future<Transaction> getTransaction(@Path("id") String id);

  @PATCH("/transactions/{id}")
  Future<Transaction> updateTransaction(
      @Path("id") String id, @Body() Map<String, dynamic> body);

  @DELETE("/transactions/{id}")
  Future<HttpResponse> deleteTransaction(@Path("id") String id);

  // Loans
  @GET("/loans")
  Future<List<Loan>> getLoans();

  @POST("/loans")
  Future<Loan> createLoan(@Body() Loan loan);

  // Rules
  @GET("/rules")
  Future<List<Rule>> getRules();

  @POST("/rules")
  Future<Rule> createRule(@Body() Rule rule);

  // AI
  @POST("/ai/insight")
  Future<InsightResponse> getInsight(@Body() Map<String, dynamic> body);

  // Notifications
  @GET("/notifications")
  Future<List<Device>> getRegisteredDevices();

  @POST("/notifications/register")
  Future<HttpResponse> registerDevice(@Body() Map<String, dynamic> body);

  @POST("/notifications/unregister")
  Future<HttpResponse> unregisterDevice(@Body() Map<String, dynamic> body);

  @POST("/notifications/send/template")
  Future<HttpResponse> sendTemplateNotification(
      @Body() NotificationTemplate body);

  // Points & Achievements
  @GET("/points")
  Future<PointTransaction> getPoints();

  @GET("/achievements")
  Future<List<Achievement>> getAchievements();
}
