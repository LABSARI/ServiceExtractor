Extension { #name : #FamixJavaLocalVariable }

{ #category : #'*Service-Extractor' }
FamixJavaLocalVariable >> hasObjectType [
	
	
	^ self declaredType isNotNil and: [self declaredType isPrimitiveType not]
]
