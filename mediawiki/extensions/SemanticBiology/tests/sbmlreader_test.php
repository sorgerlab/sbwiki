<?php

$mwRoot = dirname(__FILE__) . '/../../..'; # XXX could break if our dir structure changes
require_once("$mwRoot/maintenance/commandLine.inc");


$parser = new SBWSbmlReader(read_model());
$model = $parser->getModel();

echo "SPECIES:\n";
foreach ($model->getSpeciesIds() as $id) {
  $species = $model->getSpecies($id);  
  echo "  ", $species->getBestName(), ": ", $species->asText(), "\n";
}
echo "\n";

echo "REACTIONS:\n";
foreach ($model->getReactionIds() as $id) {
  $reaction = $model->getReaction($id);  
  echo "  ", $reaction->getBestName(), ": ", $reaction->asText(), "\n";
}
echo "\n";

echo "PARAMETERS:\n";
foreach ($model->getParameterIds() as $id) {
  $parameter = $model->getParameter($id);  
  echo "  ", $parameter->getBestName(), ": ", $parameter->asText(), "\n";
}
echo "\n";





function read_model()
{
  return
'<?xml version="1.0" encoding="UTF-8"?>
<sbml xmlns="http://www.sbml.org/sbml/level2" metaid="_647564" level="2" version="1">
  <model metaid="_000001" id="Goldbeter1995" name="Goldbeter1995_CircClock">
    <notes>
      <body xmlns="http://www.w3.org/1999/xhtml">
        <p>This model originates from BioModels Database: A Database of Annotated Published Models. It is copyright (c) 2005-2008 The BioModels Team.
        
        <br/>For more information see the 
        
        <a href="http://www.ebi.ac.uk/biomodels/legal.html" target="_blank">terms of use</a>.
        
        <br/>To cite BioModels Database, please use 
        
        <a href="http://www.pubmedcentral.nih.gov/articlerender.fcgi?tool=pubmed&amp;pubmedid=16381960" target="_blank"> Le Novère N., Bornstein B., Broicher A., Courtot M., Donizelli M., Dharuri H., Li L., Sauro H., Schilstra M., Shapiro B., Snoep J.L., Hucka M. (2006) BioModels Database: A Free, Centralized Database of Curated, Published, Quantitative Kinetic Models of Biochemical and Cellular Systems Nucleic Acids Res., 34: D689-D691.</a>
      </p>
    </body>
  </notes>
  <annotation>
    <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
      <rdf:Description rdf:about="#_000001">
        <dc:creator rdf:parseType="Resource">
          <rdf:Bag>
            <rdf:li rdf:parseType="Resource">
              <vCard:N rdf:parseType="Resource">
                <vCard:Family>Le Novère</vCard:Family>
                <vCard:Given>Nicolas</vCard:Given>
              </vCard:N>
              <vCard:EMAIL>lenov@ebi.ac.uk</vCard:EMAIL>
              <vCard:ORG>
                <vCard:Orgname>EMBL-EBI</vCard:Orgname>
              </vCard:ORG>
            </rdf:li>
            <rdf:li rdf:parseType="Resource">
              <vCard:N rdf:parseType="Resource">
                <vCard:Family>Shapiro</vCard:Family>
                <vCard:Given>Bruce</vCard:Given>
              </vCard:N>
              <vCard:EMAIL>bshapiro@jpl.nasa.gov</vCard:EMAIL>
              <vCard:ORG>
                <vCard:Orgname>NASA Jet Propulsion Laboratory</vCard:Orgname>
              </vCard:ORG>
            </rdf:li>
          </rdf:Bag>
        </dc:creator>
        <dcterms:created rdf:parseType="Resource">
          <dcterms:W3CDTF>2005-06-29T10:17:21Z</dcterms:W3CDTF>
        </dcterms:created>
        <dcterms:modified rdf:parseType="Resource">
          <dcterms:W3CDTF>2008-08-21T11:43:17Z</dcterms:W3CDTF>
        </dcterms:modified>
        <bqmodel:is>
          <rdf:Bag>
            <rdf:li rdf:resource="urn:miriam:biomodels.db:BIOMD0000000016"/>
          </rdf:Bag>
        </bqmodel:is>
        <bqmodel:isDescribedBy>
          <rdf:Bag>
            <rdf:li rdf:resource="urn:miriam:pubmed:8587874"/>
          </rdf:Bag>
        </bqmodel:isDescribedBy>
        <bqbiol:isVersionOf>
          <rdf:Bag>
            <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0007623"/>
          </rdf:Bag>
        </bqbiol:isVersionOf>
        <bqbiol:is>
          <rdf:Bag>
            <rdf:li rdf:resource="urn:miriam:taxonomy:7227"/>
            <rdf:li rdf:resource="urn:miriam:kegg.pathway:dme04710"/>
          </rdf:Bag>
        </bqbiol:is>
      </rdf:Description>
    </rdf:RDF>
  </annotation>
  <listOfUnitDefinitions>
    <unitDefinition metaid="metaid_0000023" id="substance" name="micromole (default)">
      <notes>
        <body xmlns="http://www.w3.org/1999/xhtml">
          <p>Default unit of substance redefined to micromole by comparison with the article. Nicolas Le Novere</p>
        </body>
      </notes>
      <listOfUnits>
        <unit kind="mole" scale="-6"/>
      </listOfUnits>
    </unitDefinition>
    <unitDefinition metaid="metaid_0000024" id="time" name="heure (default)">
      <notes>
        <body xmlns="http://www.w3.org/1999/xhtml">
          <p>Default unit of time redefined to hour by comparison with the article. Nicolas Le Novere</p>
        </body>
      </notes>
      <listOfUnits>
        <unit kind="second" multiplier="3600"/>
      </listOfUnits>
    </unitDefinition>
  </listOfUnitDefinitions>
  <listOfCompartments>
    <compartment metaid="_741863" id="default" size="1e-15"/>
    <compartment metaid="_741901" id="CYTOPLASM" size="1e-15" outside="default">
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_741901">
            <bqbiol:is>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0005737"/>
              </rdf:Bag>
            </bqbiol:is>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
    </compartment>
    <compartment metaid="metaid_0000026" id="compartment_0000004" name="NUCLEUS" size="1e-15" outside="CYTOPLASM">
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#metaid_0000026">
            <bqbiol:is>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0005634"/>
              </rdf:Bag>
            </bqbiol:is>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
    </compartment>
  </listOfCompartments>
  <listOfSpecies>
    <species metaid="_741921" id="EmptySet" compartment="default" initialAmount="0" boundaryCondition="true" constant="true">
      <notes>
        <body xmlns="http://www.w3.org/1999/xhtml">
          <p>boundaryCondition changed from default (i.e. false) to true, because EmptySet acts as a reactant. Nicolas Le Novere</p>
        </body>
      </notes>
    </species>
    <species metaid="_741942" id="M" name="PER mRNA" compartment="CYTOPLASM" initialConcentration="0.1">
      <notes>
        <body xmlns="http://www.w3.org/1999/xhtml">
          <p>Initial condition changed from amount to concentration as per article. Bruce Shapiro</p>
        </body>
      </notes>
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_741942">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:obo.chebi:CHEBI%3A33699"/>
                <rdf:li rdf:resource="urn:miriam:kegg.compound:C00046"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
    </species>
    <species metaid="_741962" id="P0" name="unphosphorylated PER" compartment="CYTOPLASM" initialConcentration="0.25">
      <notes>
        <body xmlns="http://www.w3.org/1999/xhtml">
          <p>Initial condition changed from amount to concentration as per article. Bruce Shapiro</p>
        </body>
      </notes>
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_741962">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:uniprot:P07663"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
    </species>
    <species metaid="_741981" id="P1" name="monophosphorylated PER" compartment="CYTOPLASM" initialConcentration="0.25">
      <notes>
        <body xmlns="http://www.w3.org/1999/xhtml">
          <p>Initial condition changed from amount to concentration as per article. Bruce Shapiro</p>
        </body>
      </notes>
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_741981">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:uniprot:P07663"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
    </species>
    <species metaid="_742001" id="P2" name="biphosphorylated PER" compartment="CYTOPLASM" initialConcentration="0.25">
      <notes>
        <body xmlns="http://www.w3.org/1999/xhtml">
          <p>Initial condition changed from amount to concentration as per article. Bruce Shapiro</p>
        </body>
      </notes>
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_742001">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:uniprot:P07663"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
    </species>
    <species metaid="_742021" id="Pn" name="nuclear PER" compartment="compartment_0000004" initialConcentration="0.25">
      <notes>
        <body xmlns="http://www.w3.org/1999/xhtml">
          <p>Initial condition changed from amount to concentration as per article. Bruce Shapiro</p>
        </body>
      </notes>
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_742021">
            <bqbiol:is>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:uniprot:P07663"/>
              </rdf:Bag>
            </bqbiol:is>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
    </species>
    <species metaid="_742041" id="Pt" name="total PER" compartment="CYTOPLASM" initialConcentration="1">
      <notes>
        <body xmlns="http://www.w3.org/1999/xhtml">
          <p>Initial condition changed from amount to concentration as per article. Bruce Shapiro</p>
          <p>initial concentration for Pt is not used becuase Pt is determined by an Assigment Rule</p>
        </body>
      </notes>
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_742041">
            <bqbiol:is>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:uniprot:P07663"/>
              </rdf:Bag>
            </bqbiol:is>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
    </species>
  </listOfSpecies>
  <listOfRules>
    <assignmentRule metaid="metaid_0000025" variable="Pt">
      <notes>
        <body xmlns="http://www.w3.org/1999/xhtml">
          <p>Conversion to number of molecules removed to give result in micromoles.</p>
          <p>Pn added to formula for consistency with reference. Bruce Shapiro </p>
        </body>
      </notes>
      <math xmlns="http://www.w3.org/1998/Math/MathML">
        <apply>
          <plus/>
          <ci> P0 </ci>
          <ci> P1 </ci>
          <ci> P2 </ci>
          <ci> Pn </ci>
        </apply>
      </math>
    </assignmentRule>
  </listOfRules>
  <listOfReactions>
    <reaction metaid="_742062" id="rM" name="transcription of PER" reversible="false">
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_742062">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0009299"/>
                <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0006355"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
      <listOfReactants>
        <speciesReference species="EmptySet"/>
      </listOfReactants>
      <listOfProducts>
        <speciesReference species="M"/>
      </listOfProducts>
      <listOfModifiers>
        <modifierSpeciesReference species="Pn"/>
      </listOfModifiers>
      <kineticLaw>
        <notes>
          <body xmlns="http://www.w3.org/1999/xhtml">
            <p>Formula modified to give units of substance/time Bruce Shapiro</p>
          </body>
        </notes>
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <divide/>
            <apply>
              <times/>
              <ci> default </ci>
              <ci> Vs </ci>
              <apply>
                <power/>
                <ci> KI </ci>
                <ci> n </ci>
              </apply>
            </apply>
            <apply>
              <plus/>
              <apply>
                <power/>
                <ci> KI </ci>
                <ci> n </ci>
              </apply>
              <apply>
                <power/>
                <ci> Pn </ci>
                <ci> n </ci>
              </apply>
            </apply>
          </apply>
        </math>
        <listOfParameters>
          <parameter id="Vs" value="0.76"/>
          <parameter id="KI" value="1"/>
          <parameter id="n" value="4"/>
        </listOfParameters>
      </kineticLaw>
    </reaction>
    <reaction metaid="_742083" id="rTL" name="translation of PER" reversible="false">
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_742083">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0043037"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
      <listOfReactants>
        <speciesReference species="EmptySet"/>
      </listOfReactants>
      <listOfProducts>
        <speciesReference species="P0"/>
      </listOfProducts>
      <listOfModifiers>
        <modifierSpeciesReference species="M"/>
      </listOfModifiers>
      <kineticLaw>
        <notes>
          <body xmlns="http://www.w3.org/1999/xhtml">
            <p>Formula modified to give units of substance/time Bruce Shapiro</p>
          </body>
        </notes>
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <times/>
            <ci> ks </ci>
            <ci> M </ci>
            <ci> default </ci>
          </apply>
        </math>
        <listOfParameters>
          <parameter id="ks" value="0.38"/>
        </listOfParameters>
      </kineticLaw>
    </reaction>
    <reaction metaid="_742102" id="rP01" name="first phosphorylation of PER" reversible="false">
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_742102">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:ec-code:2.7.11.1"/>
                <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0006468"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
      <listOfReactants>
        <speciesReference species="P0"/>
      </listOfReactants>
      <listOfProducts>
        <speciesReference species="P1"/>
      </listOfProducts>
      <kineticLaw>
        <notes>
          <body xmlns="http://www.w3.org/1999/xhtml">
            <p>Formula modified to give units of substance/time Bruce Shapiro</p>
          </body>
        </notes>
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <divide/>
            <apply>
              <times/>
              <ci> CYTOPLASM </ci>
              <ci> V1 </ci>
              <ci> P0 </ci>
            </apply>
            <apply>
              <plus/>
              <ci> K1 </ci>
              <ci> P0 </ci>
            </apply>
          </apply>
        </math>
        <listOfParameters>
          <parameter id="V1" value="3.2"/>
          <parameter id="K1" value="2"/>
        </listOfParameters>
      </kineticLaw>
    </reaction>
    <reaction metaid="_742122" id="rP10" name="removal of the first PER phosphate" reversible="false">
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_742122">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:ec-code:3.1.3.16"/>
                <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0006470"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
      <listOfReactants>
        <speciesReference species="P1"/>
      </listOfReactants>
      <listOfProducts>
        <speciesReference species="P0"/>
      </listOfProducts>
      <kineticLaw>
        <notes>
          <body xmlns="http://www.w3.org/1999/xhtml">
            <p>Formula modified to give units of substance/time Bruce Shapiro</p>
          </body>
        </notes>
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <divide/>
            <apply>
              <times/>
              <ci> CYTOPLASM </ci>
              <ci> V2 </ci>
              <ci> P1 </ci>
            </apply>
            <apply>
              <plus/>
              <ci> K2 </ci>
              <ci> P1 </ci>
            </apply>
          </apply>
        </math>
        <listOfParameters>
          <parameter id="V2" value="1.58"/>
          <parameter id="K2" value="2"/>
        </listOfParameters>
      </kineticLaw>
    </reaction>
    <reaction metaid="_742142" id="rP12" name="second phosphorylation of PER" reversible="false">
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_742142">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:ec-code:2.7.11.1"/>
                <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0006468"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
      <listOfReactants>
        <speciesReference species="P1"/>
      </listOfReactants>
      <listOfProducts>
        <speciesReference species="P2"/>
      </listOfProducts>
      <kineticLaw>
        <notes>
          <body xmlns="http://www.w3.org/1999/xhtml">
            <p>Formula modified to give units of substance/time Bruce Shapiro</p>
          </body>
        </notes>
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <divide/>
            <apply>
              <times/>
              <ci> CYTOPLASM </ci>
              <ci> V3 </ci>
              <ci> P1 </ci>
            </apply>
            <apply>
              <plus/>
              <ci> K3 </ci>
              <ci> P1 </ci>
            </apply>
          </apply>
        </math>
        <listOfParameters>
          <parameter id="V3" value="5"/>
          <parameter id="K3" value="2"/>
        </listOfParameters>
      </kineticLaw>
    </reaction>
    <reaction metaid="_742162" id="rP21" name="removal of the second PER phosphate" reversible="false">
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_742162">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:ec-code:3.1.3.16"/>
                <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0006470"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
      <listOfReactants>
        <speciesReference species="P2"/>
      </listOfReactants>
      <listOfProducts>
        <speciesReference species="P1"/>
      </listOfProducts>
      <kineticLaw>
        <notes>
          <body xmlns="http://www.w3.org/1999/xhtml">
            <p>Formula modified to give units of substance/time Bruce Shapiro</p>
          </body>
        </notes>
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <divide/>
            <apply>
              <times/>
              <ci> CYTOPLASM </ci>
              <ci> V4 </ci>
              <ci> P2 </ci>
            </apply>
            <apply>
              <plus/>
              <ci> K4 </ci>
              <ci> P2 </ci>
            </apply>
          </apply>
        </math>
        <listOfParameters>
          <parameter id="V4" value="2.5"/>
          <parameter id="K4" value="2"/>
        </listOfParameters>
      </kineticLaw>
    </reaction>
    <reaction metaid="_742182" id="rP2n" name="translocation of PER to the nucleus" reversible="false">
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_742182">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0006606"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
      <listOfReactants>
        <speciesReference species="P2"/>
      </listOfReactants>
      <listOfProducts>
        <speciesReference species="Pn"/>
      </listOfProducts>
      <kineticLaw>
        <notes>
          <body xmlns="http://www.w3.org/1999/xhtml">
            <p>Formula modified to give units of substance/time Bruce Shapiro</p>
          </body>
        </notes>
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <times/>
            <ci> k1 </ci>
            <ci> P2 </ci>
            <ci> CYTOPLASM </ci>
          </apply>
        </math>
        <listOfParameters>
          <parameter id="k1" value="1.9"/>
        </listOfParameters>
      </kineticLaw>
    </reaction>
    <reaction metaid="_742202" id="rPn2" name="translocation of PER to the cytoplasm" reversible="false">
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_742202">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0006611"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
      <listOfReactants>
        <speciesReference species="Pn"/>
      </listOfReactants>
      <listOfProducts>
        <speciesReference species="P2"/>
      </listOfProducts>
      <kineticLaw>
        <notes>
          <body xmlns="http://www.w3.org/1999/xhtml">
            <p>Formula modified to give units of substance/time Bruce Shapiro</p>
          </body>
        </notes>
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <times/>
            <ci> k2 </ci>
            <ci> Pn </ci>
            <ci> compartment_0000004 </ci>
          </apply>
        </math>
        <listOfParameters>
          <parameter id="k2" value="1.3"/>
        </listOfParameters>
      </kineticLaw>
    </reaction>
    <reaction metaid="_742222" id="rmRNAd" name="degradation of PER mRNA" reversible="false">
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_742222">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0006402"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
      <listOfReactants>
        <speciesReference species="M"/>
      </listOfReactants>
      <listOfProducts>
        <speciesReference species="EmptySet"/>
      </listOfProducts>
      <kineticLaw>
        <notes>
          <body xmlns="http://www.w3.org/1999/xhtml">
            <p>Formula modified to give units of substance/time Bruce Shapiro</p>
          </body>
        </notes>
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <divide/>
            <apply>
              <times/>
              <ci> Vm </ci>
              <ci> M </ci>
              <ci> CYTOPLASM </ci>
            </apply>
            <apply>
              <plus/>
              <ci> Km </ci>
              <ci> M </ci>
            </apply>
          </apply>
        </math>
        <listOfParameters>
          <parameter id="Km" value="0.5"/>
          <parameter id="Vm" value="0.65"/>
        </listOfParameters>
      </kineticLaw>
    </reaction>
    <reaction metaid="_742242" id="rVd" name="degradation of PER" reversible="false">
      <annotation>
        <rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:dcterms="http://purl.org/dc/terms/" xmlns:vCard="http://www.w3.org/2001/vcard-rdf/3.0#" xmlns:bqbiol="http://biomodels.net/biology-qualifiers/" xmlns:bqmodel="http://biomodels.net/model-qualifiers/">
          <rdf:Description rdf:about="#_742242">
            <bqbiol:isVersionOf>
              <rdf:Bag>
                <rdf:li rdf:resource="urn:miriam:obo.go:GO%3A0006402"/>
              </rdf:Bag>
            </bqbiol:isVersionOf>
          </rdf:Description>
        </rdf:RDF>
      </annotation>
      <listOfReactants>
        <speciesReference species="P2"/>
      </listOfReactants>
      <listOfProducts>
        <speciesReference species="EmptySet"/>
      </listOfProducts>
      <kineticLaw>
        <notes>
          <body xmlns="http://www.w3.org/1999/xhtml">
            <p>Formula modified to give units of substance/time Bruce Shapiro</p>
          </body>
        </notes>
        <math xmlns="http://www.w3.org/1998/Math/MathML">
          <apply>
            <divide/>
            <apply>
              <times/>
              <ci> CYTOPLASM </ci>
              <ci> Vd </ci>
              <ci> P2 </ci>
            </apply>
            <apply>
              <plus/>
              <ci> Kd </ci>
              <ci> P2 </ci>
            </apply>
          </apply>
        </math>
        <listOfParameters>
          <parameter id="Vd" value="0.95"/>
          <parameter id="Kd" value="0.2"/>
        </listOfParameters>
      </kineticLaw>
    </reaction>
  </listOfReactions>
</model>
</sbml>
'
;
}

?>
