//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

List phoneNumberVariantsList({
  String? phonenumber,
  String? countrycode,
}) {
  List list = [
    '+${countrycode!.substring(1)}$phonenumber',
    '+${countrycode.substring(1)}-$phonenumber',
    '${countrycode.substring(1)}-$phonenumber',
    '${countrycode.substring(1)}$phonenumber',
    '0${countrycode.substring(1)}$phonenumber',
    '0$phonenumber',
    '$phonenumber',
    '+$phonenumber',
    '+${countrycode.substring(1)}--$phonenumber',
    '00$phonenumber',
    '00${countrycode.substring(1)}$phonenumber',
    '+${countrycode.substring(1)}-0$phonenumber',
    '+${countrycode.substring(1)}0$phonenumber',
    '${countrycode.substring(1)}0$phonenumber',
  ];
  return list;
}
