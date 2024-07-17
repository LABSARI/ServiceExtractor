Extension { #name : #FamixJavaParameter }

{ #category : #'*Service-Extractor' }
FamixJavaParameter >> callGraphLabel [

	^ String streamContents: [ :s |
		  | type |
		  type := self parentBehaviouralEntity.
		  s
			  nextPutAll: type mooseNameWithDots;
			  nextPut: $.;
			  nextPutAll: self name ]
]

{ #category : #'*Service-Extractor' }
FamixJavaParameter >> hasObjectType [
	
	^ self declaredType isNotNil and: [self declaredType isPrimitiveType not]
]
