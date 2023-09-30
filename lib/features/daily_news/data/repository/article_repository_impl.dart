import 'dart:io';

import 'package:news_app_clean_architecture/core/constants/constants.dart';
import 'package:news_app_clean_architecture/core/resources/data_state.dart';
import 'package:news_app_clean_architecture/features/daily_news/data/data_sources/remote/news_api_service.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/entities/article.dart';
import 'package:news_app_clean_architecture/features/daily_news/domain/repository/article_repository.dart';
import 'package:dio/dio.dart';
import '../data_sources/local/app_database.dart';
import '../models/article.dart';

class ArticleRepositoryImpl implements ArticleRepository {
  final NewsApiService _newsApiService;
  final AppDatabase _database;
  ArticleRepositoryImpl(this._newsApiService,this._database);

  @override
  Future<DataState<List<ArticleModel>>> getNewsArticles() async {
     try {
       final httpResponse = await _newsApiService.getNewsArticles(
         apiKey: newsAPIKey,
         country: countryQuery,
         category: categoryQuery,
       );

       if (httpResponse.response.statusCode == HttpStatus.ok) {
         return DataSuccess(httpResponse.data);
       } else {
         return DataFailed(DioError(
             error: httpResponse.response.statusMessage,
             response: httpResponse.response,
             type: DioErrorType.response,
             requestOptions: httpResponse.response.requestOptions
         ));
       }
     } on DioError catch(e) {
       return DataFailed(e);
     }
  }

  @override
  Future<List<ArticleEntity>> getSavedArticles() async{
    return _database.articleDAO.getArticles();
  }

  @override
  Future<void> removeArticle(ArticleEntity article) {
    return _database.articleDAO.deleteArticle(ArticleModel.fromEntity(article));
  }

  @override
  Future<void> saveArticle(ArticleEntity article) {
    return _database.articleDAO.insertArticle(ArticleModel.fromEntity(article));
  }


}