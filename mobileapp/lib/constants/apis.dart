const baseUrl = "https://aayurveda.stime.in";
const categoriesApi = "$baseUrl/wp-json/wp/v2/categories";
const childcategoriesApi = "$baseUrl/wp-json/wp/v2/categories?parent=";
const postsApi = "$baseUrl/wp-json/wp/v2/posts?categories=";
const postApi = "$baseUrl/wp-json/wp/v2/posts/";
const mediaimageApi = "$baseUrl/wp-json/wp/v2/media/";
const searchApi = "$baseUrl/wp-json/wp/v2/posts?search=";

// Auth endpoints
const signupApi = "$baseUrl/wp-json/aayurveda/v1/signup";
const loginApi = "$baseUrl/wp-json/aayurveda/v1/login";
const logoutApi = "$baseUrl/wp-json/aayurveda/v1/logout";
const socialLoginApi = "$baseUrl/wp-json/aayurveda/v1/social-login";

// Like endpoints
String likeApi(int postId) => "$baseUrl/wp-json/aayurveda/v1/posts/$postId/like";
String likedCheckApi(int postId) => "$baseUrl/wp-json/aayurveda/v1/posts/$postId/liked";
const likedPostsApi = "$baseUrl/wp-json/aayurveda/v1/user/liked-posts";

// Comment endpoints
String commentsApi(int postId, {int page = 1, int perPage = 10}) =>
    "$baseUrl/wp-json/wp/v2/comments?post=$postId&per_page=$perPage&page=$page&order=desc";
String addCommentApi(int postId) =>
    "$baseUrl/wp-json/aayurveda/v1/posts/$postId/comments";

// Moderation endpoints
String reportCommentApi(int commentId) =>
    "$baseUrl/wp-json/aayurveda/v1/comments/$commentId/report";
String blockUserApi(int userId) =>
    "$baseUrl/wp-json/aayurveda/v1/users/$userId/block";
const blockedUsersApi = "$baseUrl/wp-json/aayurveda/v1/user/blocked";

// Profile endpoints
const updateProfileApi = "$baseUrl/wp-json/aayurveda/v1/user/profile";
const deleteAccountApi = "$baseUrl/wp-json/aayurveda/v1/user/account";
const mediaUploadApi = "$baseUrl/wp-json/wp/v2/media";

// Recommendations & tips
const recommendationsApi = "$baseUrl/wp-json/aayurveda/v1/user/recommendations";
const popularPostsApi = "$baseUrl/wp-json/aayurveda/v1/popular-posts";
const dailyTipApi = "$baseUrl/wp-json/aayurveda/v1/daily-tip";

// @deprecated Use loginApi/signupApi instead
const ajaxApi = "$baseUrl/wp-content/themes/stime/ajax.php";
