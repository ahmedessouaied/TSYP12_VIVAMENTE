import 'package:country_pickers/country.dart';
import 'package:country_pickers/utils/utils.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import '../structures/structs.dart';

part 'welcome_message.dart';
part 'chat.dart';
part 'game_card.dart';
part 'loading_screen.dart';
part 'snack_bar.dart';

Widget buildCupertinoSelectedItem(Country country) {
  return Row(
    children: <Widget>[
      CountryPickerUtils.getDefaultFlagImage(country),
      const SizedBox(width: 8.0),
      Text("+${country.phoneCode}"),
      const SizedBox(width: 8.0),
      Flexible(child: Text(country.isoCode))
    ],
  );
}


Widget buildPhoneNumberField(
    TextEditingController phoneNumberController,
    Country country,
    Function fn,
    ) {
  return TextFormField(
    scrollPadding: EdgeInsets.zero,
    controller: phoneNumberController,
    validator: (value) {
      if (value == null || value.isEmpty) {
        return "Please enter a valid phone number";
      } else if (value.length < 6) {
        return "Phone number is too short";
      }
      return null;
    },
    decoration: InputDecoration(
      labelText: "Phone Number",
      border: const OutlineInputBorder(),
      prefix: IconButton(
        icon: CountryPickerUtils.getDefaultFlagImage(country),
        onPressed: () async {
          fn();
        },
        padding: EdgeInsets.zero, // Remove the default padding
      ),
      isDense: true, // Make the text field more compact
    ),
    keyboardType: TextInputType.phone,
  );
}

Widget settingScreenItem(
    BuildContext context, {
      IconData? icon,
      String? imagePath,
      required String itemName,
      required page,
    }) {
  final theme = Theme.of(context);

  return ListTile(
    leading: SizedBox(
      width: 24,
      height: 24,
      child: icon != null
          ? Center(child: Icon(icon, color: theme.primaryColor, size: 22))
          : imagePath != null
          ? Center(child: Image.asset(imagePath, width: 20, height: 20))
          : null,
    ),
    title: Text(itemName, style: theme.textTheme.titleSmall),
    onTap: () {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => page)
      );
    },
  );
}


Widget buildTextField(
    BuildContext context, TextEditingController controller, String label,
    {bool obscureText = false, String? Function(String?)? validator}) {
  final theme = Theme.of(context);
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      border: const OutlineInputBorder(),
      fillColor: theme.inputDecorationTheme.fillColor,
      filled: true,
    ),
    style: theme.textTheme.titleSmall,
    obscureText: obscureText,
    validator: validator ??
            (value) {
          if (value == null || value.isEmpty) {
            return "Please enter $label";
          }
          return null;
        },
  );
}
