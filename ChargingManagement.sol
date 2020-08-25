pragma solidity 0.5.1;

import 'browser/libreriasERC20.sol';

contract ChargingManagement is ERC20 {
    using SafeMath for uint256;
    
    
 //#######################################################################################################################
 //############################                   STRUCT           #######################################################
 //#######################################################################################################################
     struct EV {
        uint256 id;
        address propietario;
        int256 battCapacity;
        int256 MaxChargingAC;
        int256 MaxChargingDC;
        int256 isChaDeMo;
        int256 isCCSCombo;
    }
    
    
     struct PDR{
        uint256 id;//identificador unico
        address owner; // empresa que despliega el contrato
        int256 MaxOutputAC;
        int256 MaxOutputDC;
        uint256 posicionPDR;
        uint256 coste;
    }
    
    struct Trabajo{
        uint256 parcela;
        uint256 precio;
    }
    
    address _empresa;
    address _token;
    address _owner;
    uint256 _amount;
    
    EV[] public _ev;
    PDR[] public _pdr;
    
    
 //########################################################################################################################
 //############################                   MAPEOS Y EVENTOS  #######################################################
 //########################################################################################################################
    mapping(address => Trabajo) _trabajos;
    
     event evAlmacenado (uint256 _id, address propietario, int256 _battCapacity, int256 _MaxChargingAC, int256 _MaxChargingDC, int256 _isChaDeMo, int256 _isCCSCombo );
     event PDRAlmacenado (uint256 _id, address owner, int256 MaxOutputAC, int256 MaxOutputDC, uint256 _coste, uint256 posicionPDR);
     
     event Transfer(address indexed _from, address indexed _to, uint256 _value);
     event NuevoTrabajo(address);
     
    modifier soloEmpresa(){ // controlo que el codigo puea ser emitido solo por la empresa
        assert(_token == _empresa);
        _;
    }
 //#######################################################################################################################
 //############################                   CONSTRUCTOR      #######################################################
 //#######################################################################################################################
 
    constructor(address token) public{
        _owner = msg.sender;
        _empresa = token;
        _token = token;
        _amount = 0;
        

    }
    
    
 //#######################################################################################################################
 //############################                   CREACION evES Y pdr     #########################################
 //#######################################################################################################################
  
   function creaev(int256 _MaxChargingAC, int256 _MaxChargingDC, int256 _isChaDeMo, int256 _battCapacity, int256 _isCCSCombo) public soloEmpresa()
    {
        EV memory ev;
          
            
        ev.battCapacity = _battCapacity;
        
        ev.id = _ev.length;
        
        ev.MaxChargingAC = _MaxChargingAC;
        
        ev.MaxChargingDC = _MaxChargingDC;
        
        ev.isChaDeMo = _isChaDeMo;
        
        
        
        ev.isCCSCombo = _isCCSCombo;
        
        ev.propietario = msg.sender;
        
        _ev.push(ev);
        
        emit evAlmacenado(ev.id, ev.propietario, ev.battCapacity ,ev.MaxChargingAC, ev.MaxChargingDC, ev.isChaDeMo, ev.isCCSCombo);
        
    }
    
   
    
    function crearPDR(int256 _MaxOutputAC, int256 _MaxOutputDC , uint256 _coste) public 
    {
      
      PDR memory pdr;
      
      pdr.id = _pdr.length;
      
      pdr.owner = msg.sender;
      
      pdr.posicionPDR = 1;
      
      pdr.MaxOutputAC = _MaxOutputAC;
      
      pdr.MaxOutputDC = _MaxOutputDC;
       
      pdr.coste = _coste;
      
      _pdr.push(pdr);
      
      emit PDRAlmacenado(pdr.id, pdr.owner, pdr.MaxOutputAC, pdr.MaxOutputDC, pdr.coste, pdr.posicionPDR);
  }
  
    function Desplazarev(uint pdrId, uint EVId) soloEmpresa() public
    { 
        _pdr[pdrId-1].posicionPDR = EVId; 

    }
  
  
 //#######################################################################################################################
 //############################                   FUNCIONES GET            #########################################
 //#######################################################################################################################
  
  
    
    function geteveLength() public view returns (uint256){
        return _ev.length;
    }
    
    function getParcelaLength() public view returns (uint256){
        return _pdr.length;
    }
  
   function getEmpresa() public view returns (address){
        return _empresa;
    }
    
    
 function getPdr(uint pdrId) public view returns(int256,int256,uint256,uint256,address) {

        return (_pdr[pdrId-1].MaxOutputAC,_pdr[pdrId-1].MaxOutputDC,
                _pdr[pdrId-1].posicionPDR,_pdr[pdrId-1].coste,
                _pdr[pdrId-1].owner);
    }
 
    function getev(uint evId) public view returns(int256, int256,int256,int256, int256, address) {

        return (_ev[evId-1].battCapacity,_ev[evId-1].MaxChargingAC,_ev[evId-1].MaxChargingDC, 
                _ev[evId-1].isChaDeMo, _ev[evId-1].isCCSCombo,_ev[evId-1].propietario);
    }
    

         
    
 //#######################################################################################################################
 //############################                  FUNCIONES RELATIVAS AL PAGO     #########################################
 //#######################################################################################################################
    
    ERC20 public libreriasERC20;


function solicitarTrabajo(uint _parcela, uint _cantidad) public{
        _trabajos[msg.sender].parcela = _parcela;
        _trabajos[msg.sender].precio = _cantidad;
        
       emit NuevoTrabajo(msg.sender);
       ERC20.approve(address(this), _cantidad);
       
       _amount = _cantidad;
}

function realizarTrabajo () external payable {
  
  
   for(uint256 did = 0; did < _ev.length; did++){
    	//if(_ev[did].alturaMax >= _pdr[did].alturaMaxPermitida){
    	_pdr[did].posicionPDR = _ev[did].id;
         require(_amount > 0, "El amount debe ser mayor a 0");
        uint256 initialSupply = _amount.mul(10 ** uint256(9));
        _mint(msg.sender, initialSupply);
        emit Transfer(msg.sender,_empresa,_amount);
        ERC20.transfer(_empresa,_amount);
	      //}
        }    
  }   
    
}
