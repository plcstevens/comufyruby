class Comufy::Constants

  # values types for TYPE_TAG
  STRING_TYPE = :STRING
  DATE_TYPE   = :DATE
  GENDER_TYPE = :GENDER
  INT_TYPE    = :INT
  FLOAT_TYPE  = :FLOAT
  LEGAL_TYPES = [STRING_TYPE, DATE_TYPE, GENDER_TYPE, INT_TYPE, FLOAT_TYPE]

  # key choices for tags
  NAME_TAG    = :name
  TYPE_TAG    = :type
  LEGAL_TAGS  = [NAME_TAG, TYPE_TAG]
end
