Extension { #name : #FamixJavaParameter }

{ #category : #'*Service-Extractor' }
FamixJavaParameter >> hasObjectType [
	
	^ self declaredType isNotNil and: [self declaredType isPrimitiveType not]
]
