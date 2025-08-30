import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'base_bloc.dart';

// Base view widget for all pages
abstract class BaseView<T extends BaseBloc> extends StatelessWidget {
  const BaseView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>(
      create: (context) => createBloc(),
      child: BlocListener<T, BaseState>(
        listener: (context, state) {
          onStateChange(context, state);
        },
        child: buildView(context),
      ),
    );
  }

  // Create bloc instance
  T createBloc();

  // Build the main view
  Widget buildView(BuildContext context);

  // Handle state changes
  void onStateChange(BuildContext context, BaseState state) {
    if (state.isError && state.errorMessage != null) {
      _showErrorSnackBar(context, state.errorMessage!);
    }
    
    if (state.isSuccess && state.message != null) {
      _showSuccessSnackBar(context, state.message!);
    }
  }

  // Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success snackbar
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

// Base view with cubit
abstract class BaseCubitView<T extends BaseCubit> extends StatelessWidget {
  const BaseCubitView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>(
      create: (context) => createCubit(),
      child: BlocListener<T, BaseState>(
        listener: (context, state) {
          onStateChange(context, state);
        },
        child: buildView(context),
      ),
    );
  }

  // Create cubit instance
  T createCubit();

  // Build the main view
  Widget buildView(BuildContext context);

  // Handle state changes
  void onStateChange(BuildContext context, BaseState state) {
    if (state.isError && state.errorMessage != null) {
      _showErrorSnackBar(context, state.errorMessage!);
    }
    
    if (state.isSuccess && state.message != null) {
      _showSuccessSnackBar(context, state.message!);
    }
  }

  // Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success snackbar
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

// Base view with multiple blocs
abstract class BaseMultiBlocView extends StatelessWidget {
  const BaseMultiBlocView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: createBlocProviders(),
      child: BlocListener<BaseBloc, BaseState>(
        listener: (context, state) {
          onStateChange(context, state);
        },
        child: buildView(context),
      ),
    );
  }

  // Create multiple bloc providers
  List<BlocProvider> createBlocProviders();

  // Build the main view
  Widget buildView(BuildContext context);

  // Handle state changes
  void onStateChange(BuildContext context, BaseState state) {
    if (state.isError && state.errorMessage != null) {
      _showErrorSnackBar(context, state.errorMessage!);
    }
    
    if (state.isSuccess && state.message != null) {
      _showSuccessSnackBar(context, state.message!);
    }
  }

  // Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success snackbar
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

// Base view with auto route
abstract class BaseAutoRouteView<T extends BaseBloc> extends StatelessWidget {
  const BaseAutoRouteView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<T>(
      create: (context) => createBloc(),
      child: BlocListener<T, BaseState>(
        listener: (context, state) {
          onStateChange(context, state);
        },
        child: Scaffold(
          appBar: buildAppBar(context),
          body: buildBody(context),
          bottomNavigationBar: buildBottomNavigationBar(context),
          floatingActionButton: buildFloatingActionButton(context),
        ),
      ),
    );
  }

  // Create bloc instance
  T createBloc();

  // Build app bar
  PreferredSizeWidget? buildAppBar(BuildContext context) => null;

  // Build body
  Widget buildBody(BuildContext context);

  // Build bottom navigation bar
  Widget? buildBottomNavigationBar(BuildContext context) => null;

  // Build floating action button
  Widget? buildFloatingActionButton(BuildContext context) => null;

  // Handle state changes
  void onStateChange(BuildContext context, BaseState state) {
    if (state.isError && state.errorMessage != null) {
      _showErrorSnackBar(context, state.errorMessage!);
    }
    
    if (state.isSuccess && state.message != null) {
      _showSuccessSnackBar(context, state.message!);
    }
  }

  // Show error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success snackbar
  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Tamam',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}
