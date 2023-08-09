import '../../controllers/fund_raising/fund_raising_controller.dart';
import '../../helper/imports/common_import.dart';
import 'donation_checkout.dart';

class EnterDonationAmount extends StatelessWidget {
  final FundRaisingController fundRaisingController = Get.find();

  EnterDonationAmount({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorConstants.backgroundColor,
      body: Column(
        children: [
          backNavigationBar(title: makePaymentString),
          Expanded(
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                AppTextField(
                  controller: fundRaisingController.donationAmountTE,
                  label: enterAmountToDonate,
                ),
                const SizedBox(
                  height: 50,
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: Get.width / 2.5,
                          child: const Center(
                            child: Heading6Text('\$10'),
                          ).p25,
                        ).borderWithRadius(value: 1, radius: 10).ripple(() {
                          fundRaisingController.setDonationAmount(10);
                        }),
                        SizedBox(
                          width: Get.width / 2.5,
                          child: const Center(
                            child: Heading6Text('\$20'),
                          ).p25,
                        ).borderWithRadius(value: 1, radius: 10).ripple(() {
                          fundRaisingController.setDonationAmount(20);
                        }),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: Get.width / 2.5,
                          child: const Center(
                            child: Heading6Text('\$50'),
                          ).p25,
                        ).borderWithRadius(value: 1, radius: 10).ripple(() {
                          fundRaisingController.setDonationAmount(50);
                        }),
                        SizedBox(
                          width: Get.width / 2.5,
                          child: const Center(
                            child: Heading6Text('\$100'),
                          ).p25,
                        ).borderWithRadius(value: 1, radius: 10).ripple(() {
                          fundRaisingController.setDonationAmount(100);
                        }),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                AppThemeButton(
                    text: makePaymentString,
                    onPress: () {
                      if (fundRaisingController
                          .donationAmountTE.text.isNotEmpty) {
                        Get.to(() => DonationCheckout(
                            order: fundRaisingController.order));
                      } else {
                        AppUtil.showToast(
                            message: pleaseEnterDonationAmountString,
                            isSuccess: false);
                      }
                    })
              ],
            ).hp(DesignConstants.horizontalPadding),
          ),
        ],
      ),
    );
  }
}
