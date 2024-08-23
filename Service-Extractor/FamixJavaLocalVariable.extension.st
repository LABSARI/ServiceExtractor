Extension { #name : 'FamixJavaLocalVariable' }

{ #category : '*Service-Extractor' }
FamixJavaLocalVariable >> callGraphLabel [

	^ String streamContents: [ :s |
		  | type |
		  type := self parentBehaviouralEntity.
		  s
			  nextPutAll: type mooseNameWithDots;
			  nextPut: $.;
			  nextPutAll: self name ]
]

{ #category : '*Service-Extractor' }
FamixJavaLocalVariable >> hasObjectType [
	
	
	^ self declaredType isNotNil and: [self declaredType isPrimitiveType not]
]
