type
  PersonObj = object
    id: int
    name: string
    email: string
    password: string
    active: bool
    createdAt: date
  PersonRef = ref PersonObj

#proc setName(person: PersonObj) =  # is protected
#  person.name = "George"           # gives an error: immutable procedure

proc setName( person: PersonRef, newName: string ) =
  person.name = newName



## included unit tests!

# only exec if call staticly
when isMainModule:
  block:

    var test_user = PersonRef( name: "Benjamin", age: 27 )
    try:
      test_user.setName( "Benny" )
      assert test_user.name == "Benny"

      setName( test_user, "Benni" )
      assert test_user.name == "Benni"

      test_user.name = "Dave"
      echo test_user.name

    except:
      doAssert false
