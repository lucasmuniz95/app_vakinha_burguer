import 'package:dw9_delivery_app/app/core/ui/styles/text_styles.dart';
import 'package:dw9_delivery_app/app/core/ui/widgets/delivery_appbar.dart';
import 'package:dw9_delivery_app/app/core/ui/widgets/delivery_button.dart';
import 'package:dw9_delivery_app/app/pages/auth/register/register_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:validatorless/validatorless.dart';

import '../../../core/ui/config/base_state/base_state.dart';
import 'register_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends BaseState<RegisterPage, RegisterController> {
  final _formKey = GlobalKey<FormState>();

  final _nameEC = TextEditingController();
  final _emailEC = TextEditingController();
  final _passwordEC = TextEditingController();

  @override
  void dispose() {
    _nameEC.dispose();
    _emailEC.dispose();
    _passwordEC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool mostraSenha = true;
    return BlocListener<RegisterController, RegisterState>(
      listener: (context, state) {
        state.status.matchAny(
          any: () => hideLoader(),
          register: () => showLoader(),
          error: () {
            hideLoader();
            showError('Erro ao registrar usuário');
          },
          sucess: () {
            hideLoader();
            showSucess('Cadastro realizado com sucesso');
            Navigator.pop(context);
          },
        );
      },
      child: Scaffold(
        appBar: DeliveryAppbar(),
        body: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text(
                'Cadastro',
                style: context.textStyles.textTitle,
              ),
              Text(
                'Preencha os campos abaixo para criar o seu cadastro',
                style: context.textStyles.textMedium.copyWith(
                  fontSize: 18,
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: Validatorless.required('Nome obrigatorio'),
                controller: _nameEC,
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: Validatorless.multiple([
                  Validatorless.email('E-mail inválido'),
                  Validatorless.required('E-mail obrigatorio'),
                ]),
                controller: _emailEC,
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Senha',
                ),
                obscureText: mostraSenha,
                validator: Validatorless.multiple([
                  Validatorless.required('Senha obrigatoria'),
                  Validatorless.min(
                      6, 'Senha deve conter pelo menos 6 caracteres'),
                ]),
                controller: _passwordEC,
              ),
              const SizedBox(
                height: 30,
              ),
              TextFormField(
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Confirma senha'),
                validator: Validatorless.multiple([
                  Validatorless.required('Confirma senha obrigatoria'),
                  Validatorless.compare(_passwordEC, 'As senhas não são iguais')
                ]),
              ),
              const SizedBox(
                height: 30,
              ),
              Center(
                child: DeliveryButton(
                  onPressed: () {
                    final valid = _formKey.currentState?.validate() ?? false;
                    if (valid) {
                      controller.register(
                          _nameEC.text, _emailEC.text, _passwordEC.text,);
                    }
                  },
                  label: 'CADASTRAR',
                  width: double.infinity,
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}
