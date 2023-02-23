import 'package:dw9_delivery_app/app/core/ui/extensions/formatter_extension.dart';
import 'package:dw9_delivery_app/app/core/ui/styles/text_styles.dart';
import 'package:dw9_delivery_app/app/core/ui/widgets/delivery_appbar.dart';
import 'package:dw9_delivery_app/app/core/ui/widgets/delivery_button.dart';
import 'package:dw9_delivery_app/app/dto/order_product_dto.dart';
import 'package:dw9_delivery_app/app/pages/order/widget/order_controller.dart';
import 'package:dw9_delivery_app/app/pages/order/widget/order_field.dart';
import 'package:dw9_delivery_app/app/pages/order/widget/order_product_tile.dart';
import 'package:dw9_delivery_app/app/pages/order/widget/order_state.dart';
import 'package:dw9_delivery_app/app/pages/order/widget/payment_types_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:validatorless/validatorless.dart';

import '../../core/ui/config/base_state/base_state.dart';
import '../../models/payment_type_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({super.key});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends BaseState<OrderPage, OrderController> {
  final formKey = GlobalKey<FormState>();
  final addressEC = TextEditingController();
  final documentEC = TextEditingController();
  int? paymentTypeId;
  final paymentTypeValid = ValueNotifier<bool>(true);

  @override
  void onReady() {
    final products =
        ModalRoute.of(context)!.settings.arguments as List<OrderProductDto>;
    controller.load(products);
  }

  void _showConfirmProductDialog(OrderConfirmDeleteProductState state) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => AlertDialog(
              title: Text(
                'Deseja excluir o produto ${state.orderProduct.product.name}?',
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      controller.cancelDeleteProcess();
                    },
                    child: Text(
                      "Cancelar",
                      style: context.textStyles.textBold
                          .copyWith(color: Colors.red),
                    )),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      controller.decrementProduct(state.index);
                    },
                    child: Text(
                      "Confirmar",
                      style: context.textStyles.textBold,
                    )),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderController, OrderState>(
      listener: (context, state) {
        state.status.matchAny(
          any: () => hideLoader(),
          loading: () => showLoader(),
          error: () {
            hideLoader();
            showError(state.errorMessage ?? 'Erro não informado');
          },
          confirmRemoveProduct: () {
            hideLoader();
            if (state is OrderConfirmDeleteProductState) {
              _showConfirmProductDialog(state);
            }
          },
          emptyBag: () {
            showInfo(
                'Sua sacola esta vazia, selecione um produto para realizar pedido');
            Navigator.pop(context, <OrderProductDto>[]);
          },
          sucess: () {
            hideLoader();
            Navigator.of(context).popAndPushNamed('/order/completed',
                result: <OrderProductDto>[]);
          },
        );
      },
      child: WillPopScope(
        onWillPop: () async {
          Navigator.of(context).pop(controller.state.orderProducts);
          return false;
        },
        child: Scaffold(
          appBar: DeliveryAppbar(),
          body: Form(
            key: formKey,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Carrinho',
                          style: context.textStyles.textTitle,
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          onPressed: () => controller.emptyBag(),
                          icon: Image.asset('assets/images/trashRegular.png'),
                        ),
                      ],
                    ),
                  ),
                ),
                BlocSelector<OrderController, OrderState,
                    List<OrderProductDto>>(
                  selector: (state) => state.orderProducts,
                  builder: (context, orderProducts) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        childCount: orderProducts.length,
                        (context, index) {
                          final orderProduct = orderProducts[index];
                          return Column(
                            children: [
                              OrderProductTile(
                                index: index,
                                orderProduct: orderProduct,
                              )
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
                SliverToBoxAdapter(
                  child: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total do pedido',
                            style: context.textStyles.textExtraBold
                                .copyWith(fontSize: 14),
                          ),
                          BlocSelector<OrderController, OrderState, double>(
                            selector: (state) => state.totalOrder,
                            builder: (context, totalOrder) {
                              return Text(
                                totalOrder.currencyPTBR,
                                style: context.textStyles.textExtraBold
                                    .copyWith(fontSize: 20),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                    ),
                    OrderField(
                      title: 'Endereço de entrega',
                      controller: addressEC,
                      validator: Validatorless.required('Endereço obrigatorio'),
                      hintText: 'Digite um endereço',
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    OrderField(
                      title: 'CPF',
                      controller: documentEC,
                      validator: Validatorless.required('CPF obrigatorio'),
                      hintText: 'Digite o CPF',
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    BlocSelector<OrderController, OrderState,
                        List<PaymentTypeModel>>(
                      selector: (state) => state.paymentTypes,
                      builder: (context, paymentTypes) {
                        return ValueListenableBuilder(
                          valueListenable: paymentTypeValid,
                          builder: (_, paymentTypeValidValue, child) {
                            return PaymentTypesField(
                              paymentTypes: paymentTypes,
                              valueChanged: (value) => paymentTypeId = value,
                              valid: true,
                              valueSelected: paymentTypeId.toString(),
                            );
                          },
                        );
                      },
                    ),
                  ]),
                ),
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Divider(
                        color: Colors.black,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: DeliveryButton(
                          label: 'FINALIZAR',
                          width: double.infinity,
                          height: 48,
                          onPressed: () {
                            final valid =
                                formKey.currentState?.validate() ?? false;
                            final paymenTypeSelected = paymentTypeId != null;
                            paymentTypeValid.value = paymenTypeSelected;
                            if (valid && paymenTypeSelected) {
                              controller.saveOrder(
                                address: addressEC.text,
                                document: documentEC.text,
                                paymentMethodId: paymentTypeId!,
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
