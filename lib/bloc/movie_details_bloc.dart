import 'dart:async';

import 'package:flutter_bloc_movies/api/omdb_api.dart';
import 'package:flutter_bloc_movies/api/tmdb_api.dart';
import 'package:flutter_bloc_movies/models/omdb_movie.dart';
import 'package:flutter_bloc_movies/models/tmdb_movie_basic.dart';
import 'package:flutter_bloc_movies/models/tmdb_movie_details.dart';
import 'package:flutter_bloc_movies/ui/details_page/movie_details_state.dart';
import 'package:rxdart/rxdart.dart';

class MovieDetailsBloc {
	TMDBApi tmdb;
	OMDBApi omdb;

	TMDBMovieBasic movie;

	MovieDetailsLoaded movieDetailsLoaded = MovieDetailsLoaded();

	MovieDetailsBloc({this.tmdb, this.omdb, this.movie}) {
		_streamController.addStream(_fetchMovieDetails(movie.id));
	}

	//the internal object whose sink/stream we can use
	final _streamController = BehaviorSubject<MovieDetailsState>();

	//the stream of movie details. use this to show the details
	Stream<MovieDetailsState> get stream => _streamController.stream;


	Stream<MovieDetailsState> _fetchMovieDetails(int movieId) async* {
		String year = movie.releaseDate?.split('-')[0];
		yield movieDetailsLoaded;

		(Future.wait([
			tmdbMovieDetailsCall(movieId),
			omdbMovieByTitleAndYearCall(year)
		]).
		then((List responses) {
			TMDBMovieDetails tmdbMovieDetails = responses.first;
			OMDBMovie omdbMovie = responses.last;

			try {
				if (tmdbMovieDetails.hasErrors()) {
					_streamController.add(MovieDetailsError(tmdbMovieDetails.status_message));
				} else {
					_streamController.add(movieDetailsLoaded.update(tmdbMovieDetails, omdbMovie));
				}
			} catch (e) {
				print('error $e');
				_streamController.add(MovieDetailsError(e));
			}
		}));

	}

	Future<OMDBMovie> omdbMovieByTitleAndYearCall(String year) {
	  return omdb.getMovieByTitleAndYear(title: movie.title,
					year: year);
	}

	Future<TMDBMovieDetails> tmdbMovieDetailsCall(int movieId) => tmdb.movieDetails(movieId: movieId);
}
