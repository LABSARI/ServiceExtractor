"
Please describe the package using the class comment of the included manifest class. The manifest class also includes other additional metadata for the package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : 'ManifestServiceExtractor',
	#superclass : 'PackageManifest',
	#category : 'Service-Extractor-Manifest',
	#package : 'Service-Extractor',
	#tag : 'Manifest'
}

{ #category : 'code-critics' }
ManifestServiceExtractor class >> ruleCodeCruftLeftInMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#JavaCallGraphModel #buildtypeGraph #false)) #'2024-10-18T11:24:50.515543+02:00') #(#(#RGPackageDefinition #(#'Service-Extractor')) #'2024-11-18T15:12:28.292497+01:00') )
]

{ #category : 'code-critics' }
ManifestServiceExtractor class >> ruleCollectionProtocolRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#'Service-Extractor')) #'2024-11-18T10:42:43.000042+01:00') )
]

{ #category : 'code-critics' }
ManifestServiceExtractor class >> ruleLongMethodsRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#JavaCallGraphModel #buildtypeGraph #false)) #'2024-10-18T11:24:41.125177+02:00') #(#(#RGPackageDefinition #(#'Service-Extractor')) #'2024-11-18T10:42:55.482814+01:00') )
]

{ #category : 'code-critics' }
ManifestServiceExtractor class >> ruleModifiesCollectionRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGPackageDefinition #(#'Service-Extractor')) #'2024-11-18T18:26:49.173022+01:00') )
]

{ #category : 'code-critics' }
ManifestServiceExtractor class >> ruleStringConcatenationRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#JavaCallGraphModel #buildtypeGraph #false)) #'2024-10-18T11:27:33.318954+02:00') #(#(#RGPackageDefinition #(#'Service-Extractor')) #'2024-11-18T10:43:03.959056+01:00') )
]

{ #category : 'code-critics' }
ManifestServiceExtractor class >> ruleUnaryAccessingMethodWithoutReturnRuleV1FalsePositive [

	<ignoreForCoverage>
	^ #(#(#(#RGMethodDefinition #(#JavaCallGraphModel #buildtypeGraph #false)) #'2024-10-18T11:28:25.803774+02:00') )
]
