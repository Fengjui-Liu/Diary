import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _localPasswordController = TextEditingController();

  bool _isLogin = true;
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _showLocalAuth = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _localPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLocalAuth() async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final password = _localPasswordController.text;

    if (password.isEmpty) {
      _showMessage('請輸入密碼');
      return;
    }

    if (!authService.hasSetPassword) {
      // 首次使用，設置密碼
      final success = await authService.setPassword(password);
      if (success) {
        setState(() {
          _showLocalAuth = false;
        });
        _showMessage('密碼設置成功');
      } else {
        _showMessage('密碼設置失敗');
      }
    } else {
      // 驗證密碼
      final isValid = await authService.verifyPassword(password);
      if (isValid) {
        setState(() {
          _showLocalAuth = false;
        });
      } else {
        _showMessage('密碼錯誤');
      }
    }
  }

  Future<void> _handleAuth() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final authService = Provider.of<AuthService>(context, listen: false);
    String? error;

    if (_isLogin) {
      error = await authService.signInWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      error = await authService.signUpWithEmail(
        _emailController.text.trim(),
        _passwordController.text,
      );
    }

    setState(() {
      _isLoading = false;
    });

    if (error == null) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } else {
      _showMessage(error);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: _showLocalAuth ? _buildLocalAuthForm() : _buildCloudAuthForm(),
          ),
        ),
      ),
    );
  }

  Widget _buildLocalAuthForm() {
    final authService = Provider.of<AuthService>(context);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.lock,
          size: 80,
          color: Color(0xFF6C63FF),
        ),
        const SizedBox(height: 24),
        Text(
          authService.hasSetPassword ? '輸入密碼' : '設置密碼',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        const SizedBox(height: 8),
        Text(
          authService.hasSetPassword ? '請輸入您的密碼以繼續' : '首次使用，請設置一個密碼',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
        ),
        const SizedBox(height: 32),
        TextField(
          controller: _localPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: '密碼',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
          ),
          onSubmitted: (_) => _handleLocalAuth(),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _handleLocalAuth,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(authService.hasSetPassword ? '解鎖' : '設置密碼'),
            ),
          ),
        ),
        const SizedBox(height: 16),
        TextButton(
          onPressed: () {
            setState(() {
              _showLocalAuth = false;
            });
          },
          child: const Text('使用雲端帳號登入'),
        ),
      ],
    );
  }

  Widget _buildCloudAuthForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.book,
            size: 80,
            color: Color(0xFF6C63FF),
          ),
          const SizedBox(height: 24),
          Text(
            _isLogin ? '歡迎回來' : '建立帳號',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            _isLogin ? '登入您的帳號' : '註冊一個新帳號',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '請輸入Email';
              }
              if (!value.contains('@')) {
                return 'Email格式不正確';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: '密碼',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return '請輸入密碼';
              }
              if (value.length < 6) {
                return '密碼至少需要6個字元';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleAuth,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(_isLogin ? '登入' : '註冊'),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_isLogin ? '還沒有帳號？' : '已經有帳號？'),
              TextButton(
                onPressed: () {
                  setState(() {
                    _isLogin = !_isLogin;
                  });
                },
                child: Text(_isLogin ? '註冊' : '登入'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _showLocalAuth = true;
              });
            },
            child: const Text('返回本地驗證'),
          ),
        ],
      ),
    );
  }
}
