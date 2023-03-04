var SelectedBankData = {balance: null, bankid: null, owner: null}
var SelectedSlot = null;
var SelectedBank = null;

$(document).ready(function(){
    $('.tooltipped').tooltip();
    $('.tabs').tabs();
});

var formatter = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
});

window.addEventListener('message', function(event) {
    switch(event.data.action) {
        case "openbank":
            OpenBank(event.data);
            break;
        case "SetupUsers":
            SetupSharedAccount(event.data)
            break;
        case "SetupTransaction":
            SetupTransaction(event.data)
            break;
        case "update":
            Update(event.data);
            break;
        case "Atualizando":
            $('.saldo-conta').html(formatter.format(event.data.novosaldo))
            break;
        case "updatefatura":
            UpdateFatura(event.data)
            break;
        case "MostrarIdentidade":
            ShowIdentidade(event.data)
            break;
    }
});

var totalgasto = 0

OpenBank = function(data,option) {
    $(".bank-container").fadeIn(750);
    totalgasto = 0
    $('.card-ownername').html(data.chardata.charinfo.firstname + ' ' + data.chardata.charinfo.lastname)
    $('.saldo-conta').html(formatter.format(data.chardata.money['bank']))
    $(".avatar-icone").css({ "background-image": "url('" + data.chardata.metadata.phone['profilepicture'] + "')" })
    $(".lista-historico").html('');

    $.each(data.historico, function (i, historico) {
        // console.log(historico.titulo)

        if (historico.tipo === "1") {
            var tipofatura = "+"
            var textinho = 'Recebeu'
            var corvalor = 'style="color: #0FA464;"'
        } else if (historico.tipo === "2") {
            var tipofatura = "-"
            var textinho = 'Pagou'
            var corvalor = ''
        } else if (historico.tipo === "3") {
            var tipofatura = "+"
            var textinho = 'Depositou'
            var corvalor = 'style="color: #0FA464;"'
        } else if (historico.tipo === "4") {
            var tipofatura = "-"
            var textinho = 'Sacou'
            var corvalor = 'style="color: red;"'
        }else if (historico.tipo === "5") {
            var tipofatura = "+"
            var textinho = 'Transf Recebida'
            var corvalor = 'style="color: #0FA464;"'
        }else if (historico.tipo === "6") {
            var tipofatura = "-"
            var textinho = 'Transf Enviada'
            var corvalor = 'style="color: red;"'
        }else if (historico.tipo === "7") {
            var tipofatura = "-"
            var textinho = 'Compra'
            var corvalor = 'style="color: red;"'
        }
        var history = '<div class="historico-item tooltipped" id="faturaid-'+historico.idfatura+'" data-position="left" data-tooltip="'+historico.descricao+'"><div class="field-nome">'+historico.titulo+'</div><div class="field-data">'+historico.data+', '+historico.hora+'</div><div class="field-tipo">'+textinho+'</div><div class="field-valor" '+corvalor+'>'+tipofatura+''+formatter.format(historico.valor)+'</div></div>';

        $(".lista-historico").append(history);
        $('#faturaid-' + historico.idfatura).tooltip()

        totalgasto = totalgasto + historico.valor
    });
    $('.movimento_quantidade').html(formatter.format(totalgasto))
}


OnClick = function(type) {
  $.post('https://reborn_banking/ClickSound', JSON.stringify({
      success: type
  }))
}

FecharBanco = function () {
    $(".bank-container").fadeOut(750); 
    $.post('https://reborn_banking/CloseApp', JSON.stringify({}))
}


CloseBankApp = function() {
    $(".bank-container").fadeOut(750);
    $('.material-tooltip').css("visibility", "hidden");
    if (SelectedBank !== null) {
     $(SelectedBank).removeClass("selected-bank");
    }
    SelectedSlot = null;
    SelectedBank = null;
    SelectedBankData = null;
    $.post('https://reborn_banking/CloseApp', JSON.stringify({}))
}

$(document).on('click', '.deposit-button', function(e) {
    e.preventDefault();
    var MoneyAmount = parseInt($("#deposit_input").val());
    if (MoneyAmount > 0) {
     $.post('https://reborn_banking/Depositar', JSON.stringify({
         AddAmount: MoneyAmount
     }))
     $("#deposit_input").val('')

     OnClick('success-click2')

    } else {
     OnClick('bank-error') 
    }  
});

$(document).on('click', '.sacar-button', function(e) {
    e.preventDefault();
    var SaqueAmount = parseInt($("#saque_input").val());
    if (SaqueAmount > 0) {
     $.post('https://reborn_banking/Sacar', JSON.stringify({
         Sacar: SaqueAmount
     }))
     $("#saque_input").val('')

     OnClick('success-click2')

    } else {
     OnClick('bank-error') 
    }  
});

$(document).on('click', '.transf-button', function(e) {
    e.preventDefault();
    var TransfAmount = parseInt($("#transf_input").val());
    var TransfAccount = document.getElementById("transfaccount_input").value;
    if (TransfAmount > 0 && TransfAccount != '') {
        $.post('https://reborn_banking/Transferir', JSON.stringify({
            Conta: TransfAccount,
            Transferir: TransfAmount
        }))
     $("#transf_input").val('')
     $("#transfaccount_input").val('')

     OnClick('success-click2')

    } else {
     OnClick('bank-error') 
    }  
});

$(document).on('click', '.logout-button', function(e) {
    e.preventDefault();
    OnClick('click')
    CloseBankApp()
});

function UpdateFatura(data) {
    $('.material-tooltip').css("visibility", "hidden");
    $(".lista-historico").html('');
    totalgasto = 0
    $.each(data.historico, function (i, historico) {
        if (historico.tipo === "1") {
            var tipofatura = "+"
            var textinho = 'Recebeu'
            var corvalor = 'style="color: #0FA464;"'
        } else if (historico.tipo === "2") {
            var tipofatura = "-"
            var textinho = 'Pagou'
            var corvalor = ''
        } else if (historico.tipo === "3") {
            var tipofatura = "+"
            var textinho = 'Depositou'
            var corvalor = 'style="color: #0FA464;"'
        } else if (historico.tipo === "4") {
            var tipofatura = "-"
            var textinho = 'Sacou'
            var corvalor = 'style="color: red;"'
        }else if (historico.tipo === "5") {
            var tipofatura = "+"
            var textinho = 'Transf Recebida'
            var corvalor = 'style="color: #0FA464;"'
        }else if (historico.tipo === "6") {
            var tipofatura = "-"
            var textinho = 'Transf Enviada'
            var corvalor = 'style="color: red;"'
        }else if (historico.tipo === "7") {
            var tipofatura = "-"
            var textinho = 'Compra'
            var corvalor = 'style="color: red;"'
        }
        var history = '<div class="historico-item tooltipped" id="faturaid-'+historico.idfatura+'" data-position="left" data-tooltip="'+historico.descricao+'"><div class="field-nome">'+historico.titulo+'</div><div class="field-data">'+historico.data+', '+historico.hora+'</div><div class="field-tipo">'+textinho+'</div><div class="field-valor" '+corvalor+'>'+tipofatura+''+formatter.format(historico.valor)+'</div></div>';

        $(".lista-historico").append(history);
        $('#faturaid-' + historico.idfatura).tooltip()

        totalgasto = totalgasto + historico.valor
    });
    $('.movimento_quantidade').html(formatter.format(totalgasto))
}

function ShowIdentidade(data) {
    $(".show-rg").fadeIn(750);
    $(".nome-sobrenome").html(data.nome);
    $(".field-nomesobrenome").html(data.sobrenome);
    $(".RG").html(data.rg);
    $(".data-nascimento").html(data.nascimento);
    $(".assinatura").html(data.assinatura);
    $(".nacionalidade").html(data.nacionalidade);
    $(".genero").html(data.genero);
    $(".foto-pessoal").css({ "background-image": "url('" + data.fotorg + "')" })

    setTimeout(function() {
        $(".show-rg").fadeOut(750);
    }, 10000) 
}