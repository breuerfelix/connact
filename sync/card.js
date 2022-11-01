import {
  TextType,
  TextListType,
  SpecialValueType,
  FNProperty,
  NProperty,
  UIDProperty,
  VCARD,
  BdayProperty,
  DateTimeType,
  TelProperty,
} from "vcard4"

// not implemented:
//REV:2022-10-26T13:21:25Z // needed?
//EMAIL;TYPE=INTERNET,HOME,pref:vla@bla.vom
//item2.URL;TYPE=pref:breuer.dev
//item2.X-ABLABEL:_$!<HomePage>!$_
//item1.ADR;TYPE=HOME,pref:;;Testaa\n700;Cologne ;;64568;Germany
//item1.X-ABADR:de


function toVCF(user) {
  const props = []

  // username always exists
  let { firstname, lastname = "" } = user
  if (!firstname) firstname = user.username

  // UID
  //UID:20425513-0567-4633-8C68-1F9876444680
  props.push(
    new UIDProperty([], new TextType(user.username))
  )

  // add name
  //FN:Test Lastname 
  //N:Lastname ;Test;;;
  props.push(
    new FNProperty([], new TextType(`${firstname} ${lastname}`)),
    new NProperty([], new SpecialValueType([
      new TextType(lastname),
      new TextType(firstname),
      new TextListType([new TextType("")]), // additional names
      new TextType(""), // honorific prefixes
      new TextListType([new TextType("")]), // honorific suffixes
    ], "nproperty"))
  )

  // birthday
  //BDAY;VALUE=date:2020-10-26
  if (user.birthday) {
    props.push(
      new BdayProperty([], new DateTimeType(user.birthday, "dateandortime"),)
    )
  }

  // phone number
  //TEL;TYPE=CELL,VOICE,pref:0154 6484846
  // TODO
  if (user.cellPhoneNumber) {
    props.push(
      new TelProperty([], new TextType(user.cellPhoneNumber))
    )
  }

  return new VCARD(props).repr()
}

export {
  toVCF,
}
