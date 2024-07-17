Extension { #name : #FamixJavaAttribute }

{ #category : #'*Service-Extractor' }
FamixJavaAttribute >> callGraphLabel [

	^ String streamContents: [ :s |
		  | type |
		  type := self parentType.
		  s
			  nextPutAll: type mooseNameWithDots;
			  nextPut: $.;
			  nextPutAll: self name ]
]

{ #category : #'*Service-Extractor' }
FamixJavaAttribute >> hasObjectType [
	
	^ self declaredType isNotNil and: [self declaredType isPrimitiveType not]
]
