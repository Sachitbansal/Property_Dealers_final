import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart' as yo;
import 'package:google_fonts/google_fonts.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:untitled/pages/house_details.dart';

class MyDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      width: size.width,
      child: Row(
        children: <Widget>[
          buildDivider(),
          buildDivider(),
        ],
      ),
    );
  }

  Expanded buildDivider() {
    return const Expanded(
      child: Divider(
        color: Colors.blue,
        height: 1.5,
      ),
    );
  }
}

class OrDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Container(
      margin: EdgeInsets.symmetric(vertical: size.height * 0.02),
      width: size.width * 0.8,
      child: Row(
        children: <Widget>[
          buildDivider(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              "OR",
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          buildDivider(),
        ],
      ),
    );
  }

  Expanded buildDivider() {
    return const Expanded(
      child: Divider(
        color: Colors.blue,
        height: 1.5,
      ),
    );
  }
}

class CustomPageRoute extends PageRouteBuilder {
  final Widget child;

  CustomPageRoute({required this.child})
      : super(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (context, animation, secondaryAnimation) => child,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child) =>
      SlideTransition(
        child: child,
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(animation),
      );
}

class RoundedButton extends StatelessWidget {
  final void Function()? press;
  final String text;
  final Color textColor;
  final Color bgColor;

  const RoundedButton(this.press, this.text, this.textColor, this.bgColor);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return SizedBox(
      // margin: EdgeInsets.symmetric(vertical: 10),
      width: size.width * 0.8,
      child: ClipRRect(
        // borderRadius: BorderRadius.circular(29),
        child: TextButton(
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
            backgroundColor: bgColor,
          ),
          onPressed: press,
          child: Text(
            text,
            style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                letterSpacing: 1.3),
          ),
        ),
      ),
    );
  }
}

class RoundedInputField extends StatelessWidget {
  RoundedInputField(
      {this.label = '',
      this.keyboardtype,
      this.controller,
      this.validator,
      this.iconChoose,
      required this.obscureText,
      required this.onChanged,
      required this.suffixiIcon,
      this.hint = ''});

  final iconChoose;
  final suffixiIcon;
  final String hint;
  final validator;
  final void Function(String) onChanged;
  final controller;
  final keyboardtype;
  final String label;
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardtype,
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      controller: controller,
      cursorColor: Colors.blue[800],
      decoration: InputDecoration(
          fillColor: Colors.blue[50],
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(width: 0.8),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: const BorderSide(
              width: 0.8,
              color: Colors.blue,
            ),
          ),
          hintText: hint,
          labelText: label,
          prefixIcon: Icon(
            iconChoose,
            color: Colors.blue,
          ),
          suffixIcon: Icon(suffixiIcon, color: Colors.blue)),
    );
  }
}

class ContactFiled extends StatelessWidget {
  const ContactFiled({
    Key? key,
    required this.onChanged,
    required this.iconData,
    required this.label,
    required this.hint,
    required this.keybaord,
  }) : super(key: key);

  final void Function(String)? onChanged;
  final IconData iconData;
  final String label, hint;
  final TextInputType keybaord;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keybaord,
      initialValue: '',
      onChanged: onChanged,
      decoration: InputDecoration(
          fillColor: Colors.blue[50],
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              width: 1,
              color: Colors.blue,
            ),
          ),
          hintText: hint,
          labelText: label,
          prefixIcon: Icon(
            iconData,
            color: Colors.blue,
          )),
    );
  }
}

InputDecoration kDecoration = InputDecoration(
  fillColor: Colors.blue[50],
  contentPadding: const EdgeInsets.symmetric(vertical: 15.0),
  filled: true,
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: const BorderSide(width: 1),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: const BorderSide(
      width: 1,
      color: Colors.blue,
    ),
  ),
);

class InfoWidget extends StatelessWidget {
  const InfoWidget({
    Key? key,
    required this.heading,
    required this.info,
  }) : super(key: key);

  final String heading, info;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          heading,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
        ),
        Text(
          info,
          style: const TextStyle(
            fontSize: 20,
          ),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}

class ReusableCard extends StatelessWidget {
  const ReusableCard(
      {required this.colour, required this.cardChild, required this.onPress});

  final Color colour;
  final Widget cardChild;
  final void Function() onPress;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPress,
      child: Container(
        child: cardChild,
        margin: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: colour,
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}

class PropertyType extends StatelessWidget {
  const PropertyType(
      {required this.name,
      required this.icon,
      required this.onTap,
      required this.color});

  final String name;
  final IconData icon;
  final void Function() onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            child: Icon(icon),
            backgroundColor: color,
          ),
          Text(name)
        ],
      ),
    );
  }
}

class Animal {
  final int id;
  final String name;

  Animal({
    required this.id,
    required this.name,
  });
}

class Select extends StatelessWidget {
  final MaterialStateProperty<Color> bgColor;
  final void Function() onPressed;
  final String text;

  const Select(
      {required this.bgColor, required this.onPressed, required this.text});

  @override
  Widget build(BuildContext context) {
    return TextButton(
        style: ButtonStyle(backgroundColor: bgColor),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18),
        ),
        onPressed: onPressed);
  }
}

class ButtonWithTextAndIcon extends StatelessWidget {
  const ButtonWithTextAndIcon(
      {Key? key,
      required this.onTap,
      required this.bgColor,
      required this.textIconColor,
      required this.title,
      required this.icon})
      : super(key: key);

  final void Function() onTap;
  final Color? bgColor;
  final Color? textIconColor;
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // width: width,
        decoration: BoxDecoration(
            color: bgColor, borderRadius: BorderRadius.circular(15.0)),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: textIconColor,
                size: 30,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                title,
                style: GoogleFonts.play(
                  color: textIconColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilterTitle extends StatelessWidget {
  const FilterTitle({
    Key? key,
    required this.title,
  }) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(
          height: 10,
        ),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}

class ButtonWithText extends StatelessWidget {
  const ButtonWithText(
      {Key? key,
      required this.onTap,
      required this.size,
      required this.title,
      required this.bgColor,
      required this.fontColor})
      : super(key: key);
  final void Function() onTap;
  final double? size;
  final String title;
  final Color? bgColor, fontColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.play(
                color: fontColor,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class NearbyHomes extends StatelessWidget {
  const NearbyHomes({
    Key? key,
    required this.asset,
    required this.name,
    required this.location,
    required this.bedCount,
    required this.bathCount,
    required this.onTap,
  }) : super(key: key);
  final List asset;
  final String name;
  final String location;
  final String bedCount;
  final String bathCount;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    disableCenter: false,
                  ),
                  items: asset
                      .map(
                        (item) => Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                item.toString(),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
            SizedBox(
              width: 100,
            ),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.play(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  location,
                  style: GoogleFonts.play(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.king_bed,
                          color: Colors.grey,
                          size: 18,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          bedCount,
                          style: GoogleFonts.play(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Row(
                      children: [
                        Icon(
                          Icons.bathtub,
                          color: Colors.grey,
                          size: 16,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          bathCount,
                          style: GoogleFonts.play(
                            color: Colors.black,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            )),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.titleController,
    required this.labelText,
    this.validator,
  }) : super(key: key);

  final TextEditingController titleController;
  final String labelText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.blue[300],
      decoration: InputDecoration(
        isCollapsed: true,
        fillColor: Colors.blue[200]?.withOpacity(0.05),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 0.8,
            color: Colors.blue[300]!,
          ),
        ),
        labelText: labelText,
      ),
      controller: titleController,
      validator: validator,
    );
  }
}
